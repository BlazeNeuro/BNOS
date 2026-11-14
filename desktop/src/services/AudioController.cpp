#include "AudioController.hpp"
#include <QProcess>
#include <algorithm>

AudioController::AudioController(QObject *parent)
    : QObject(parent)
{
}

void AudioController::setVolume(int vol)
{
    int clamped = std::clamp(vol, 0, 100);
    if (m_volume == clamped) return;

    m_volume = clamped;
    applyVolume();
    emit volumeChanged();
}

void AudioController::toggleMute()
{
    m_isMuted = !m_isMuted;
    // Pipewire wpctl: wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    QProcess::startDetached("wpctl", QStringList() << "set-mute" << "@DEFAULT_AUDIO_SINK@" << "toggle");
    emit isMutedChanged();
}

void AudioController::applyVolume()
{
    // Pipewire wpctl: wpctl set-volume @DEFAULT_AUDIO_SINK@ 70%
    double frac = m_volume / 100.0;
    QProcess::startDetached("wpctl", QStringList() << "set-volume" << "@DEFAULT_AUDIO_SINK@" << QString::number(frac, 'f', 2));
}
