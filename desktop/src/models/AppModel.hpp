#pragma once

#include <QAbstractListModel>
#include <QString>
#include <QList>
#include <QProcess>

struct AppEntry {
    QString name;
    QString exec;
    QString icon;
    QString comment;
    QString category;
    bool terminal = false;
};

class AppModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QString filterText READ filterText WRITE setFilterText NOTIFY filterTextChanged)
    Q_PROPERTY(QString categoryFilter READ categoryFilter WRITE setCategoryFilter NOTIFY categoryFilterChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum AppRoles {
        NameRole = Qt::UserRole + 1,
        ExecRole,
        IconRole,
        CommentRole,
        CategoryRole,
        TerminalRole
    };

    explicit AppModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    QString filterText() const { return m_filterText; }
    void setFilterText(const QString &text);

    QString categoryFilter() const { return m_categoryFilter; }
    void setCategoryFilter(const QString &cat);

    int count() const { return m_filteredApps.size(); }

    Q_INVOKABLE void launch(int index);
    Q_INVOKABLE void launchByExec(const QString &execCmd, bool terminal = false);
    Q_INVOKABLE void reload();

signals:
    void filterTextChanged();
    void categoryFilterChanged();
    void countChanged();
    void appLaunched(const QString &name);

private:
    void scanDirectories();
    void parseDesktopFile(const QString &filePath);
    void applyFilter();

    QList<AppEntry> m_allApps;
    QList<AppEntry> m_filteredApps;
    QString m_filterText;
    QString m_categoryFilter = "All Apps";
};
