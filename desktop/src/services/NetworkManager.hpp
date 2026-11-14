#pragma once

#include <QObject>
#include <QTimer>

class NetworkManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool connected READ connected NOTIFY connectedChanged)
    Q_PROPERTY(QString connectionName READ connectionName NOTIFY connectionNameChanged)
    Q_PROPERTY(bool isWifi READ isWifi NOTIFY isWifiChanged)
    Q_PROPERTY(int signalStrength READ signalStrength NOTIFY signalStrengthChanged)

public:
    explicit NetworkManager(QObject *parent = nullptr);

    bool connected() const { return m_connected; }
    QString connectionName() const { return m_connectionName; }
    bool isWifi() const { return m_isWifi; }
    int signalStrength() const { return m_signalStrength; }

    Q_INVOKABLE void refresh();

signals:
    void connectedChanged();
    void connectionNameChanged();
    void isWifiChanged();
    void signalStrengthChanged();

private:
    void checkNetwork();

    bool m_connected = true;
    QString m_connectionName = "Connected";
    bool m_isWifi = true;
    int m_signalStrength = 85;
    QTimer *m_timer = nullptr;
};
