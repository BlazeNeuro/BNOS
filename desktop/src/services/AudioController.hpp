#pragma once

#include <QObject>

class AudioController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int volume READ volume WRITE setVolume NOTIFY volumeChanged)
    Q_PROPERTY(bool isMuted READ isMuted NOTIFY isMutedChanged)

public:
    explicit AudioController(QObject *parent = nullptr);

    int volume() const { return m_volume; }
    void setVolume(int vol);

    bool isMuted() const { return m_isMuted; }

    Q_INVOKABLE void toggleMute();

signals:
    void volumeChanged();
    void isMutedChanged();

private:
    void applyVolume();

    int m_volume = 70;
    bool m_isMuted = false;
};
