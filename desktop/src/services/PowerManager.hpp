#pragma once

#include <QObject>
#include <QTimer>

class PowerManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int batteryPercentage READ batteryPercentage NOTIFY batteryPercentageChanged)
    Q_PROPERTY(bool isCharging READ isCharging NOTIFY isChargingChanged)
    Q_PROPERTY(bool hasBattery READ hasBattery NOTIFY hasBatteryChanged)
    Q_PROPERTY(QString statusText READ statusText NOTIFY statusTextChanged)

public:
    explicit PowerManager(QObject *parent = nullptr);

    int batteryPercentage() const { return m_batteryPercentage; }
    bool isCharging() const { return m_isCharging; }
    bool hasBattery() const { return m_hasBattery; }
    QString statusText() const { return m_statusText; }

    Q_INVOKABLE void refresh();

signals:
    void batteryPercentageChanged();
    void isChargingChanged();
    void hasBatteryChanged();
    void statusTextChanged();

private:
    void readSysfs();

    int m_batteryPercentage = 100;
    bool m_isCharging = false;
    bool m_hasBattery = false;
    QString m_statusText = "AC Power";
    QTimer *m_timer = nullptr;
};
