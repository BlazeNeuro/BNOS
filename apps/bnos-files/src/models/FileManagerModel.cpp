#include "FileManagerModel.hpp"
#include <QStandardPaths>
#include <QMimeDatabase>
#include <QMimeType>
#include <QCollator>
#include <algorithm>

FileManagerModel::FileManagerModel(QObject *parent)
    : QAbstractListModel(parent)
{
    QString home = QDir::homePath();
    openPath(home);
}

int FileManagerModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) return 0;
    return m_items.size();
}

QVariant FileManagerModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_items.size())
        return QVariant();

    const FileItem &item = m_items[index.row()];

    switch (role) {
    case NameRole: return item.name;
    case PathRole: return item.path;
    case IsDirRole: return item.isDir;
    case SizeRole: return item.size;
    case FormattedSizeRole: return item.formattedSize;
    case ModifiedRole: return item.modified;
    case IconNameRole: return item.iconName;
    case MimeTypeRole: return item.mimeType;
    case IsHiddenRole: return item.isHidden;
    default: return QVariant();
    }
}

QHash<int, QByteArray> FileManagerModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    roles[PathRole] = "path";
    roles[IsDirRole] = "isDir";
    roles[SizeRole] = "size";
    roles[FormattedSizeRole] = "formattedSize";
    roles[ModifiedRole] = "modified";
    roles[IconNameRole] = "iconName";
    roles[MimeTypeRole] = "mimeType";
    roles[IsHiddenRole] = "isHidden";
    return roles;
}

QString FileManagerModel::currentDirName() const
{
    if (m_currentPath == QDir::rootPath())
        return "File System";
    if (m_currentPath == QDir::homePath())
        return "Home";
    return QFileInfo(m_currentPath).fileName();
}

void FileManagerModel::openPath(const QString &path)
{
    QDir dir(path);
    if (!dir.exists()) {
        emit errorOccurred(QString("Directory does not exist: %1").arg(path));
        return;
    }

    QString canonical = dir.canonicalPath();
    if (canonical.isEmpty()) canonical = path;

    // Manage history
    if (m_historyIndex < 0 || (m_historyIndex < m_history.size() && m_history[m_historyIndex] != canonical)) {
        // Truncate any forward history
        while (m_history.size() > m_historyIndex + 1) {
            m_history.removeLast();
        }
        m_history.append(canonical);
        m_historyIndex = m_history.size() - 1;
        emit historyChanged();
    }

    m_currentPath = canonical;
    loadDirectory(m_currentPath);
    emit currentPathChanged();
}

void FileManagerModel::goBack()
{
    if (m_historyIndex > 0) {
        m_historyIndex--;
        m_currentPath = m_history[m_historyIndex];
        loadDirectory(m_currentPath);
        emit currentPathChanged();
        emit historyChanged();
    }
}

void FileManagerModel::goForward()
{
    if (m_historyIndex < m_history.size() - 1) {
        m_historyIndex++;
        m_currentPath = m_history[m_historyIndex];
        loadDirectory(m_currentPath);
        emit currentPathChanged();
        emit historyChanged();
    }
}

void FileManagerModel::goUp()
{
    QDir dir(m_currentPath);
    if (dir.cdUp()) {
        openPath(dir.canonicalPath());
    }
}

void FileManagerModel::openItem(int index)
{
    if (index < 0 || index >= m_items.size()) return;

    const FileItem &item = m_items[index];
    if (item.isDir) {
        openPath(item.path);
    } else {
        openFilePath(item.path);
    }
}

void FileManagerModel::openFilePath(const QString &path)
{
    emit itemOpened(path);
    // Use xdg-open or QDesktopServices
    bool launched = QDesktopServices::openUrl(QUrl::fromLocalFile(path));
    if (!launched) {
        QProcess::startDetached("xdg-open", QStringList() << path);
    }
}

bool FileManagerModel::createFolder(const QString &folderName)
{
    if (folderName.isEmpty()) return false;
    QDir dir(m_currentPath);
    if (dir.mkdir(folderName)) {
        refresh();
        return true;
    }
    emit errorOccurred(QString("Failed to create folder '%1'").arg(folderName));
    return false;
}

bool FileManagerModel::deleteItem(const QString &path)
{
    QFileInfo info(path);
    bool ok = false;
    if (info.isDir()) {
        QDir dir(path);
        ok = dir.removeRecursively();
    } else {
        QFile file(path);
        ok = file.remove();
    }

    if (ok) {
        refresh();
    } else {
        emit errorOccurred(QString("Failed to delete '%1'").arg(info.fileName()));
    }
    return ok;
}

bool FileManagerModel::renameItem(const QString &oldPath, const QString &newName)
{
    if (newName.isEmpty()) return false;
    QFileInfo info(oldPath);
    QString newPath = info.dir().filePath(newName);
    
    QFile file(oldPath);
    if (file.rename(newPath)) {
        refresh();
        return true;
    }
    emit errorOccurred(QString("Failed to rename to '%1'").arg(newName));
    return false;
}

void FileManagerModel::search(const QString &query)
{
    if (query.trimmed().isEmpty()) {
        beginResetModel();
        m_items = m_allItems;
        endResetModel();
        emit itemCountChanged();
        return;
    }

    QString lower = query.toLower();
    QVector<FileItem> filtered;
    for (const auto &item : m_allItems) {
        if (item.name.toLower().contains(lower)) {
            filtered.append(item);
        }
    }

    beginResetModel();
    m_items = filtered;
    endResetModel();
    emit itemCountChanged();
}

void FileManagerModel::refresh()
{
    loadDirectory(m_currentPath);
}

void FileManagerModel::loadDirectory(const QString &path)
{
    beginResetModel();
    m_items.clear();
    m_allItems.clear();

    QDir dir(path);
    QDir::Filters filters = QDir::AllEntries | QDir::NoDotAndDotDot;
    if (m_showHidden) filters |= QDir::Hidden;

    QFileInfoList entries = dir.entryInfoList(filters, QDir::DirsFirst | QDir::Name);

    // Natural sort
    QCollator collator;
    collator.setNumericMode(true);
    std::sort(entries.begin(), entries.end(), [&collator](const QFileInfo &a, const QFileInfo &b) {
        if (a.isDir() != b.isDir()) return a.isDir();
        return collator.compare(a.fileName(), b.fileName()) < 0;
    });

    QMimeDatabase mimeDb;

    for (const QFileInfo &info : entries) {
        FileItem item;
        item.name = info.fileName();
        item.path = info.canonicalFilePath();
        item.isDir = info.isDir();
        item.size = info.isDir() ? 0 : info.size();
        item.formattedSize = item.isDir ? "" : formatBytes(item.size);
        item.modified = info.lastModified().toString("MMM d, yyyy h:mm AP");
        item.iconName = detectIcon(info);
        item.mimeType = mimeDb.mimeTypeForFile(info).name();
        item.isHidden = info.isHidden();

        m_items.append(item);
    }

    m_allItems = m_items;
    endResetModel();
    emit itemCountChanged();
}

QString FileManagerModel::detectIcon(const QFileInfo &info) const
{
    if (info.isDir()) return "folder";

    QString ext = info.suffix().toLower();

    // Code & Scripting
    if (ext == "cpp" || ext == "hpp" || ext == "c" || ext == "h" ||
        ext == "py" || ext == "rs" || ext == "js" || ext == "ts" ||
        ext == "qml" || ext == "html" || ext == "css" || ext == "json" ||
        ext == "sh" || ext == "cmake" || ext == "toml" || ext == "yaml" || ext == "yml") {
        return "code";
    }

    // Text & Documents
    if (ext == "txt" || ext == "md" || ext == "pdf" || ext == "doc" ||
        ext == "docx" || ext == "odt" || ext == "rtf") {
        return "file";
    }

    // Media
    if (ext == "mp3" || ext == "wav" || ext == "flac" || ext == "ogg" || ext == "m4a") {
        return "volume";
    }
    if (ext == "mp4" || ext == "mkv" || ext == "webm" || ext == "avi" || ext == "mov") {
        return "monitor";
    }
    if (ext == "png" || ext == "jpg" || ext == "jpeg" || ext == "svg" || ext == "webp" || ext == "gif") {
        return "monitor";
    }

    return "file";
}

QString FileManagerModel::formatBytes(qint64 bytes) const
{
    if (bytes < 1024) return QString("%1 B").arg(bytes);
    double kb = bytes / 1024.0;
    if (kb < 1024) return QString("%1 KB").arg(kb, 0, 'f', 1);
    double mb = kb / 1024.0;
    if (mb < 1024) return QString("%1 MB").arg(mb, 0, 'f', 1);
    double gb = mb / 1024.0;
    return QString("%1 GB").arg(gb, 0, 'f', 2);
}

// Shortcuts
QString FileManagerModel::getHomePath() const { return QDir::homePath(); }
QString FileManagerModel::getDesktopPath() const {
    QString p = QStandardPaths::writableLocation(QStandardPaths::DesktopLocation);
    return p.isEmpty() ? QDir::homePath() + "/Desktop" : p;
}
QString FileManagerModel::getDocumentsPath() const {
    QString p = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    return p.isEmpty() ? QDir::homePath() + "/Documents" : p;
}
QString FileManagerModel::getDownloadsPath() const {
    QString p = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
    return p.isEmpty() ? QDir::homePath() + "/Downloads" : p;
}
QString FileManagerModel::getPicturesPath() const {
    QString p = QStandardPaths::writableLocation(QStandardPaths::PicturesLocation);
    return p.isEmpty() ? QDir::homePath() + "/Pictures" : p;
}
QString FileManagerModel::getMusicPath() const {
    QString p = QStandardPaths::writableLocation(QStandardPaths::MusicLocation);
    return p.isEmpty() ? QDir::homePath() + "/Music" : p;
}
QString FileManagerModel::getVideosPath() const {
    QString p = QStandardPaths::writableLocation(QStandardPaths::MoviesLocation);
    return p.isEmpty() ? QDir::homePath() + "/Videos" : p;
}
QString FileManagerModel::getProjectsPath() const {
    QString p = QDir::homePath() + "/Projects";
    QDir().mkpath(p);
    return p;
}
QString FileManagerModel::getRootPath() const { return QDir::rootPath(); }
