#include "NetworkManager.hpp"
#include <QDir>
#include <QFile>
#include <QTextStream>
#include <QProcess>

NetworkManager::NetworkManager(QObject *parent)
    : QObject(parent)
{
    m_timer = new QTimer(this);
    connect(m_timer, &QTimer::timeout, this, &NetworkManager::checkNetwork);
    m_timer->start(15000); // Check every 15 seconds

    checkNetwork();
}

void NetworkManager::refresh()
{
    checkNetwork();
}

void NetworkManager::checkNetwork()
{
    QDir netDir("/sys/class/net");
    if (!netDir.exists()) return;

    const auto interfaces = netDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);
    bool anyUp = false;

    for (const QString &iface : interfaces) {
        if (iface == "lo") continue;

        QFile operstateFile(netDir.absoluteFilePath(iface + "/operstate"));
        if (operstateFile.open(QIODevice::ReadOnly)) {
            QTextStream in(&operstateFile);
            QString state = in.readLine().trimmed();
            if (state == "up") {
                anyUp = true;
                bool isWireless = iface.startsWith("wl");
                m_isWifi = isWireless;
                m_connectionName = isWireless ? "Wi-Fi (" + iface + ")" : "Ethernet (" + iface + ")";
                emit isWifiChanged();
                emit connectionNameChanged();
                break;
            }
        }
    }

    if (m_connected != anyUp) {
        m_connected = anyUp;
        emit connectedChanged();
    }
}
