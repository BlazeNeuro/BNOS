#include "AppModel.hpp"
#include <QDir>
#include <QFile>
#include <QTextStream>
#include <QStandardPaths>
#include <QRegularExpression>
#include <algorithm>

AppModel::AppModel(QObject *parent)
    : QAbstractListModel(parent)
{
    reload();
}

int AppModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) return 0;
    return m_filteredApps.size();
}

QVariant AppModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_filteredApps.size())
        return QVariant();

    const auto &item = m_filteredApps.at(index.row());

    switch (role) {
    case NameRole: return item.name;
    case ExecRole: return item.exec;
    case IconRole: return item.icon;
    case CommentRole: return item.comment;
    case CategoryRole: return item.category;
    case TerminalRole: return item.terminal;
    default: return QVariant();
    }
}

QHash<int, QByteArray> AppModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    roles[ExecRole] = "exec";
    roles[IconRole] = "icon";
    roles[CommentRole] = "comment";
    roles[CategoryRole] = "category";
    roles[TerminalRole] = "terminal";
    return roles;
}

void AppModel::setFilterText(const QString &text)
{
    if (m_filterText == text) return;
    m_filterText = text;
    applyFilter();
    emit filterTextChanged();
}

void AppModel::setCategoryFilter(const QString &cat)
{
    if (m_categoryFilter == cat) return;
    m_categoryFilter = cat;
    applyFilter();
    emit categoryFilterChanged();
}

void AppModel::reload()
{
    scanDirectories();
    applyFilter();
}

void AppModel::scanDirectories()
{
    m_allApps.clear();

    QStringList appDirs = {
        "/usr/share/applications",
        "/usr/local/share/applications",
        QStandardPaths::writableLocation(QStandardPaths::ApplicationsLocation)
    };

    QSet<QString> processedFiles;

    for (const QString &dirPath : appDirs) {
        QDir dir(dirPath);
        if (!dir.exists()) continue;

        const auto files = dir.entryList(QStringList() << "*.desktop", QDir::Files);
        for (const QString &fileName : files) {
            if (processedFiles.contains(fileName)) continue;
            processedFiles.insert(fileName);
            parseDesktopFile(dir.absoluteFilePath(fileName));
        }
    }

    // Default system apps fallback if scanning finds few or none (e.g. testing in container)
    if (m_allApps.isEmpty()) {
        m_allApps.append({"Terminal", "foot", "terminal", "Terminal Emulator", "Development", false});
        m_allApps.append({"File Manager", "thunar", "folder", "Explore Files", "System", false});
        m_allApps.append({"Web Browser", "firefox-esr", "fire", "Browse the Web", "Productivity", false});
        m_allApps.append({"BNOS Settings", "bnos-settings", "settings", "System Settings", "System", false});
        m_allApps.append({"System Monitor", "foot -e htop", "cpu", "Monitor Resources", "System", false});
    }

    // Sort alphabetically by name
    std::sort(m_allApps.begin(), m_allApps.end(), [](const AppEntry &a, const AppEntry &b) {
        return a.name.compare(b.name, Qt::CaseInsensitive) < 0;
    });
}

void AppModel::parseDesktopFile(const QString &filePath)
{
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) return;

    QTextStream in(&file);
    bool inDesktopEntry = false;
    AppEntry entry;
    bool noDisplay = false;

    while (!in.atEnd()) {
        QString line = in.readLine().trimmed();
        if (line == "[Desktop Entry]") {
            inDesktopEntry = true;
            continue;
        }
        if (line.startsWith("[") && line.endsWith("]")) {
            inDesktopEntry = false;
            continue;
        }
        if (!inDesktopEntry) continue;

        if (line.startsWith("Name=") && entry.name.isEmpty()) {
            entry.name = line.mid(5).trimmed();
        } else if (line.startsWith("Exec=") && entry.exec.isEmpty()) {
            QString cmd = line.mid(5).trimmed();
            // Remove %f, %F, %u, %U field codes
            cmd.remove(QRegularExpression("%[fFuUdiDnNickvm]"));
            entry.exec = cmd.trimmed();
        } else if (line.startsWith("Icon=") && entry.icon.isEmpty()) {
            entry.icon = line.mid(5).trimmed();
        } else if (line.startsWith("Comment=") && entry.comment.isEmpty()) {
            entry.comment = line.mid(8).trimmed();
        } else if (line.startsWith("Categories=")) {
            QString cats = line.mid(11).toLower();
            if (cats.contains("development") || cats.contains("ide") || cats.contains("utility")) {
                entry.category = "Development";
            } else if (cats.contains("office") || cats.contains("network") || cats.contains("webbrowser")) {
                entry.category = "Productivity";
            } else {
                entry.category = "System";
            }
        } else if (line.startsWith("Terminal=")) {
            entry.terminal = (line.mid(9).trimmed().toLower() == "true");
        } else if (line.startsWith("NoDisplay=")) {
            noDisplay = (line.mid(10).trimmed().toLower() == "true");
        }
    }

    if (!noDisplay && !entry.name.isEmpty() && !entry.exec.isEmpty()) {
        if (entry.category.isEmpty()) entry.category = "System";
        if (entry.icon.isEmpty()) entry.icon = "grid";
        m_allApps.append(entry);
    }
}

void AppModel::applyFilter()
{
    beginResetModel();
    m_filteredApps.clear();

    QString query = m_filterText.trimmed().toLower();
    bool matchAllCats = (m_categoryFilter == "All Apps" || m_categoryFilter.isEmpty());

    for (const auto &item : m_allApps) {
        bool catMatch = matchAllCats || (item.category == m_categoryFilter);
        bool queryMatch = query.isEmpty() ||
                          item.name.toLower().contains(query) ||
                          item.comment.toLower().contains(query) ||
                          item.exec.toLower().contains(query);

        if (catMatch && queryMatch) {
            m_filteredApps.append(item);
        }
    }

    endResetModel();
    emit countChanged();
}

void AppModel::launch(int index)
{
    if (index < 0 || index >= m_filteredApps.size()) return;
    const auto &item = m_filteredApps.at(index);
    launchByExec(item.exec, item.terminal);
    emit appLaunched(item.name);
}

void AppModel::launchByExec(const QString &execCmd, bool terminal)
{
    if (execCmd.isEmpty()) return;

    if (terminal) {
        QProcess::startDetached("foot", QStringList() << "-e" << execCmd);
    } else {
        // Use bash / xdg-open or split arguments
        QProcess::startDetached("/bin/sh", QStringList() << "-c" << execCmd);
    }
}
