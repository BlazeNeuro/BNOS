#pragma once

#include <QAbstractListModel>
#include <QString>
#include <QVector>
#include <QProcess>
#include <QFile>

struct SoftwareApp {
    QString id;
    QString name;
    QString category;
    QString description;
    QString iconName;
    QString packageName;
    QString binaryName;
    QString version;
    bool isInstalled;
    bool isInstalling;
};

class SoftwareManager : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int totalApps READ totalApps NOTIFY appsChanged)
    Q_PROPERTY(int installedCount READ installedCount NOTIFY appsChanged)
    Q_PROPERTY(QString activeCategory READ activeCategory WRITE setCategory NOTIFY categoryChanged)

public:
    enum AppRoles {
        IdRole = Qt::UserRole + 1,
        NameRole,
        CategoryRole,
        DescriptionRole,
        IconNameRole,
        PackageNameRole,
        BinaryNameRole,
        VersionRole,
        IsInstalledRole,
        IsInstallingRole
    };

    explicit SoftwareManager(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    int totalApps() const { return m_filteredApps.size(); }
    int installedCount() const;
    QString activeCategory() const { return m_activeCategory; }

public slots:
    void setCategory(const QString &category);
    void search(const QString &query);
    void installApp(int index);
    void removeApp(int index);
    void launchApp(int index);
    void refresh();

signals:
    void appsChanged();
    void categoryChanged();
    void installStarted(const QString &appName);
    void installFinished(const QString &appName, bool success);

private:
    void initCatalog();
    void updateInstalledStatus();
    void applyFilter();

    QVector<SoftwareApp> m_allApps;
    QVector<SoftwareApp> m_filteredApps;
    QString m_activeCategory = "All";
    QString m_searchQuery = "";
};
