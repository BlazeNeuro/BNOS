#include "SystemManager.hpp"
#include <QProcess>
#include <QFile>
#include <QTextStream>
#include <QHostInfo>
#include <sys/utsname.h>
#include <unistd.h>

SystemManager::SystemManager(QObject *parent)
    : QObject(parent)
{
}

QString SystemManager::username() const
{
    QString user = qEnvironmentVariable("USER");
    if (user.isEmpty()) user = qEnvironmentVariable("LOGNAME");
    if (user.isEmpty()) user = "ankit";
    return user;
}

QString SystemManager::hostname() const
{
    return QHostInfo::localHostName();
}

QString SystemManager::kernelVersion() const
{
    struct utsname buf;
    if (uname(&buf) == 0) {
        return QString::fromUtf8(buf.release);
    }
    return "Linux 6.x";
}

QString SystemManager::uptimeString() const
{
    QFile file("/proc/uptime");
    if (file.open(QIODevice::ReadOnly)) {
        QTextStream in(&file);
        double uptimeSec = 0;
        in >> uptimeSec;
        int hours = static_cast<int>(uptimeSec) / 3600;
        int minutes = (static_cast<int>(uptimeSec) % 3600) / 60;
        return QString("%1h %2m").arg(hours).arg(minutes);
    }
    return "0m";
}

bool SystemManager::callLogindMethod(const QString &method)
{
    QDBusInterface logind(
        "org.freedesktop.login1",
        "/org/freedesktop/login1",
        "org.freedesktop.login1.Manager",
        QDBusConnection::systemBus()
    );

    if (logind.isValid()) {
        QDBusReply<void> reply = logind.call(method, true);
        if (reply.isValid()) return true;
    }
    return false;
}

void SystemManager::powerOff()
{
    emit actionExecuted("Shutting down");
    if (!callLogindMethod("PowerOff")) {
        QProcess::startDetached("systemctl", QStringList() << "poweroff");
    }
}

void SystemManager::reboot()
{
    emit actionExecuted("Rebooting");
    if (!callLogindMethod("Reboot")) {
        QProcess::startDetached("systemctl", QStringList() << "reboot");
    }
}

void SystemManager::suspend()
{
    emit actionExecuted("Suspending");
    if (!callLogindMethod("Suspend")) {
        QProcess::startDetached("systemctl", QStringList() << "suspend");
    }
}

void SystemManager::lockSession()
{
    emit actionExecuted("Session locked");
    // Handled in shell state + logind lock if registered
}
