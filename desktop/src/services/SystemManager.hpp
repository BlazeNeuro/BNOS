#pragma once

#include <QObject>
#include <QString>
#include <QDBusInterface>
#include <QDBusReply>

class SystemManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString username READ username CONSTANT)
    Q_PROPERTY(QString hostname READ hostname CONSTANT)
    Q_PROPERTY(QString kernelVersion READ kernelVersion CONSTANT)
    Q_PROPERTY(QString osName READ osName CONSTANT)
    Q_PROPERTY(QString osVersion READ osVersion CONSTANT)
    Q_PROPERTY(QString uptimeString READ uptimeString NOTIFY uptimeChanged)

public:
    explicit SystemManager(QObject *parent = nullptr);

    QString username() const;
    QString hostname() const;
    QString kernelVersion() const;
    QString osName() const { return "BNOS"; }
    QString osVersion() const { return "1.0 (Trixie)"; }
    QString uptimeString() const;

    Q_INVOKABLE void powerOff();
    Q_INVOKABLE void reboot();
    Q_INVOKABLE void suspend();
    Q_INVOKABLE void lockSession();
    Q_INVOKABLE void launchCommand(const QString &command);

signals:
    void uptimeChanged();
    void actionExecuted(const QString &action);

private:
    bool callLogindMethod(const QString &method);
};
