#pragma once

#include <QAbstractListModel>
#include <QFileInfo>
#include <QDir>
#include <QStringList>
#include <QDateTime>
#include <QDesktopServices>
#include <QUrl>
#include <QVector>
#include <QProcess>

struct FileItem {
    QString name;
    QString path;
    bool isDir;
    qint64 size;
    QString formattedSize;
    QString modified;
    QString iconName;
    QString mimeType;
    bool isHidden;
};

class FileManagerModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QString currentPath READ currentPath WRITE openPath NOTIFY currentPathChanged)
    Q_PROPERTY(QString currentDirName READ currentDirName NOTIFY currentPathChanged)
    Q_PROPERTY(bool canGoBack READ canGoBack NOTIFY historyChanged)
    Q_PROPERTY(bool canGoForward READ canGoForward NOTIFY historyChanged)
    Q_PROPERTY(int itemCount READ itemCount NOTIFY itemCountChanged)

public:
    enum FileRoles {
        NameRole = Qt::UserRole + 1,
        PathRole,
        IsDirRole,
        SizeRole,
        FormattedSizeRole,
        ModifiedRole,
        IconNameRole,
        MimeTypeRole,
        IsHiddenRole
    };

    explicit FileManagerModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    QString currentPath() const { return m_currentPath; }
    QString currentDirName() const;
    bool canGoBack() const { return m_historyIndex > 0; }
    bool canGoForward() const { return m_historyIndex < m_history.size() - 1; }
    int itemCount() const { return m_items.size(); }

public slots:
    void openPath(const QString &path);
    void goBack();
    void goForward();
    void goUp();
    void openItem(int index);
    void openFilePath(const QString &path);
    bool createFolder(const QString &folderName);
    bool deleteItem(const QString &path);
    bool renameItem(const QString &oldPath, const QString &newName);
    void search(const QString &query);
    void refresh();

    // Standard folder shortcuts
    QString getHomePath() const;
    QString getDesktopPath() const;
    QString getDocumentsPath() const;
    QString getDownloadsPath() const;
    QString getPicturesPath() const;
    QString getMusicPath() const;
    QString getVideosPath() const;
    QString getProjectsPath() const;
    QString getRootPath() const;

signals:
    void currentPathChanged();
    void historyChanged();
    void itemCountChanged();
    void errorOccurred(const QString &message);
    void itemOpened(const QString &path);

private:
    void loadDirectory(const QString &path);
    QString formatBytes(qint64 bytes) const;
    QString detectIcon(const QFileInfo &info) const;

    QString m_currentPath;
    QVector<FileItem> m_items;
    QVector<FileItem> m_allItems; // For search filtering
    QStringList m_history;
    int m_historyIndex = -1;
    bool m_showHidden = false;
};
