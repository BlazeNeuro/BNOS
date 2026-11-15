#include "SoftwareManager.hpp"
#include <QStandardPaths>
#include <QDir>
#include <QDebug>

SoftwareManager::SoftwareManager(QObject *parent)
    : QAbstractListModel(parent)
{
    initCatalog();
    updateInstalledStatus();
    applyFilter();
}

int SoftwareManager::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) return 0;
    return m_filteredApps.size();
}

QVariant SoftwareManager::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_filteredApps.size())
        return QVariant();

    const SoftwareApp &app = m_filteredApps[index.row()];

    switch (role) {
    case IdRole: return app.id;
    case NameRole: return app.name;
    case CategoryRole: return app.category;
    case DescriptionRole: return app.description;
    case IconNameRole: return app.iconName;
    case PackageNameRole: return app.packageName;
    case BinaryNameRole: return app.binaryName;
    case VersionRole: return app.version;
    case IsInstalledRole: return app.isInstalled;
    case IsInstallingRole: return app.isInstalling;
    default: return QVariant();
    }
}

QHash<int, QByteArray> SoftwareManager::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "id";
    roles[NameRole] = "name";
    roles[CategoryRole] = "category";
    roles[DescriptionRole] = "description";
    roles[IconNameRole] = "iconName";
    roles[PackageNameRole] = "packageName";
    roles[BinaryNameRole] = "binaryName";
    roles[VersionRole] = "version";
    roles[IsInstalledRole] = "isInstalled";
    roles[IsInstallingRole] = "isInstalling";
    return roles;
}

int SoftwareManager::installedCount() const
{
    int count = 0;
    for (const auto &app : m_allApps) {
        if (app.isInstalled) count++;
    }
    return count;
}

void SoftwareManager::setCategory(const QString &category)
{
    if (m_activeCategory != category) {
        m_activeCategory = category;
        applyFilter();
        emit categoryChanged();
    }
}

void SoftwareManager::search(const QString &query)
{
    m_searchQuery = query.trimmed().toLower();
    applyFilter();
}

void SoftwareManager::installApp(int index)
{
    if (index < 0 || index >= m_filteredApps.size()) return;

    SoftwareApp &app = m_filteredApps[index];
    app.isInstalling = true;
    QModelIndex idx = createIndex(index, 0);
    emit dataChanged(idx, idx, {IsInstallingRole});
    emit installStarted(app.name);

    // Run apt-get install asynchronously
    QString pkg = app.packageName;
    QProcess *proc = new QProcess(this);
    connect(proc, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, [this, pkg, proc](int exitCode) {
        for (auto &a : m_allApps) {
            if (a.packageName == pkg) {
                a.isInstalling = false;
                a.isInstalled = (exitCode == 0);
                emit installFinished(a.name, exitCode == 0);
                break;
            }
        }
        applyFilter();
        proc->deleteLater();
    });

    proc->start("sudo", QStringList() << "apt-get" << "install" << "-y" << pkg);
}

void SoftwareManager::removeApp(int index)
{
    if (index < 0 || index >= m_filteredApps.size()) return;

    SoftwareApp &app = m_filteredApps[index];
    app.isInstalling = true;
    QModelIndex idx = createIndex(index, 0);
    emit dataChanged(idx, idx, {IsInstallingRole});

    QString pkg = app.packageName;
    QProcess *proc = new QProcess(this);
    connect(proc, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, [this, pkg, proc](int exitCode) {
        for (auto &a : m_allApps) {
            if (a.packageName == pkg) {
                a.isInstalling = false;
                a.isInstalled = (exitCode != 0);
                break;
            }
        }
        applyFilter();
        proc->deleteLater();
    });

    proc->start("sudo", QStringList() << "apt-get" << "remove" << "-y" << pkg);
}

void SoftwareManager::launchApp(int index)
{
    if (index < 0 || index >= m_filteredApps.size()) return;
    const SoftwareApp &app = m_filteredApps[index];
    if (app.isInstalled && !app.binaryName.isEmpty()) {
        QProcess::startDetached(app.binaryName, QStringList());
    }
}

void SoftwareManager::refresh()
{
    updateInstalledStatus();
    applyFilter();
}

void SoftwareManager::initCatalog()
{
    m_allApps = {
        {"firefox", "Firefox ESR", "Internet", "Fast, private, and secure modern web browser from Mozilla.", "globe", "firefox-esr", "firefox-esr", "128.0", false, false},
        {"foot", "Foot Terminal", "Utilities", "Ultra-fast, lightweight Wayland native terminal emulator.", "terminal", "foot", "foot", "1.21", true, false},
        {"thunar", "Thunar File Manager", "Utilities", "Traditional GTK file manager for browsing drives and folders.", "folder", "thunar", "thunar", "4.18", true, false},
        {"fastfetch", "Fastfetch", "Utilities", "Neofetch-like tool for fetching system information and stats.", "info", "fastfetch", "fastfetch", "2.30", true, false},
        {"vlc", "VLC Media Player", "Multimedia", "Universal multimedia player capable of playing any audio/video codec.", "monitor", "vlc", "vlc", "3.0.20", false, false},
        {"gimp", "GIMP Image Editor", "Multimedia", "Professional open source raster graphics and photo editing suite.", "monitor", "gimp", "gimp", "2.10", false, false},
        {"code", "VS Code (OSS)", "Development", "Open-source build of the world's most popular code editor.", "code", "code", "code", "1.95", false, false},
        {"git", "Git Version Control", "Development", "Fast, scalable, distributed revision control system.", "code", "git", "git", "2.45", true, false},
        {"python", "Python 3 Runtime", "Development", "Next-generation programming language and development toolchain.", "code", "python3", "python3", "3.12", true, false},
        {"libreoffice", "LibreOffice Suite", "Productivity", "Full-featured office suite: Writer, Calc, Impress, Draw.", "file", "libreoffice", "libreoffice", "24.8", false, false},
        {"htop", "Htop System Monitor", "System", "Interactive process viewer and hardware resource telemetry tool.", "cpu", "htop", "htop", "3.3", false, false},
        {"obs", "OBS Studio", "Multimedia", "Free and open source software for video recording and live streaming.", "monitor", "obs-studio", "obs", "30.2", false, false}
    };
}

void SoftwareManager::updateInstalledStatus()
{
    for (auto &app : m_allApps) {
        if (!app.binaryName.isEmpty()) {
            QString path = QStandardPaths::findExecutable(app.binaryName);
            app.isInstalled = !path.isEmpty();
        }
    }
}

void SoftwareManager::applyFilter()
{
    beginResetModel();
    m_filteredApps.clear();

    for (const auto &app : m_allApps) {
        bool matchesCategory = (m_activeCategory == "All") ||
                               (m_activeCategory == "Installed" && app.isInstalled) ||
                               (app.category == m_activeCategory);

        bool matchesSearch = m_searchQuery.isEmpty() ||
                             app.name.toLower().contains(m_searchQuery) ||
                             app.description.toLower().contains(m_searchQuery) ||
                             app.packageName.toLower().contains(m_searchQuery);

        if (matchesCategory && matchesSearch) {
            m_filteredApps.append(app);
        }
    }

    endResetModel();
    emit appsChanged();
}
