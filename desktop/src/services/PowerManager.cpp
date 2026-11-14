#include "PowerManager.hpp"
#include <QDir>
#include <QFile>
#include <QTextStream>

PowerManager::PowerManager(QObject *parent)
    : QObject(parent)
{
    m_timer = new QTimer(this);
    connect(m_timer, &QTimer::timeout, this, &PowerManager::refresh);
    m_timer->start(10000); // Poll every 10 seconds

    refresh();
}

void PowerManager::refresh()
{
    readSysfs();
}

void PowerManager::readSysfs()
{
    QDir powerDir("/sys/class/power_supply");
    if (!powerDir.exists()) {
        m_hasBattery = false;
        m_batteryPercentage = 100;
        m_statusText = "AC Connected";
        return;
    }

    const auto entries = powerDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);
    bool foundBattery = false;

    for (const QString &entry : entries) {
        if (entry.startsWith("BAT")) {
            foundBattery = true;
            m_hasBattery = true;

            // Read capacity
            QFile capFile(powerDir.absoluteFilePath(entry + "/capacity"));
            if (capFile.open(QIODevice::ReadOnly)) {
                QTextStream in(&capFile);
                int cap = in.readLine().trimmed().toInt();
                if (cap != m_batteryPercentage) {
                    m_batteryPercentage = cap;
                    emit batteryPercentageChanged();
                }
            }

            // Read status
            QFile statusFile(powerDir.absoluteFilePath(entry + "/status"));
            if (statusFile.open(QIODevice::ReadOnly)) {
                QTextStream in(&statusFile);
                QString st = in.readLine().trimmed();
                bool charging = (st == "Charging");
                if (charging != m_isCharging) {
                    m_isCharging = charging;
                    emit isChargingChanged();
                }
                m_statusText = st;
                emit statusTextChanged();
            }
            break;
        }
    }

    if (!foundBattery) {
        m_hasBattery = false;
        m_batteryPercentage = 100;
        m_isCharging = true;
        m_statusText = "Desktop / AC";
        emit hasBatteryChanged();
        emit batteryPercentageChanged();
        emit isChargingChanged();
        emit statusTextChanged();
    }
}
