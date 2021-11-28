#include "backlight.h"

Backlight::Backlight(): QObject()
{
    /* find valid backlight path; search here: */
    m_path = "/sys/class/backlight/";

    try
    {
        QDir dir(m_path);
        QFileInfoList list = dir.entryInfoList();
        m_path =  list.at(2).absoluteFilePath();
        m_backlightOK = true;
    }
    catch (...)
    {
        m_backlightOK = false;
    }

    m_maxBrightness = getMaxBrightness();

    /* set lockBrightness to about half maxBrightness,
     * unlockBrightness to full maxBrightness
     * and blankBrightness to 0
     * until they are set to their final values
     */
    m_lockBrightness = m_maxBrightness >> 1;
    m_unlockBrightness = m_maxBrightness;
    m_brightness = getBrightness();
    m_blankBrightness = 0;
    m_blankEnable = true;

    setBLEnable(1);
}


void Backlight::setLockBrightness(int brightness)
{
    /* restrict brightness to  0 <-> maxBrightness */
    if (brightness < 0 || brightness > m_maxBrightness) {
        if (brightness < 0)
            brightness = 0;
        else
            brightness = m_maxBrightness;
    }

    m_lockBrightness = brightness;

    return;
}


void Backlight::setUnlockBrightness(int brightness)
{
    /* restrict brightness to  0 <-> maxBrightness */
    if (brightness < 0 || brightness > m_maxBrightness) {
        if (brightness < 0)
            brightness = 0;
        else
            brightness = m_maxBrightness;
    }

    m_unlockBrightness = brightness;

    return;
}


void Backlight::setBlankBrightness(int brightness)
{
    /* restrict brightness to  0 <-> maxBrightness */
    if (brightness < 0 || brightness > m_maxBrightness) {
        if (brightness < 0)
            brightness = 0;
        else
            brightness = m_maxBrightness;
    }

    m_blankBrightness = brightness;

    return;
}


void Backlight::setBlankPowerOff(bool enable)
{
    m_blankEnable = enable;
    return;
}


int Backlight::getMaxBrightness()
{
    int maxBrightness;

    if (m_backlightOK == false)
        return 0;

    QFile blFile(m_path + "/max_brightness");

    if (!blFile.open(QIODevice::ReadOnly | QIODevice::Text))
            return 0;
    char buffer[6];
    qint64 linelength = blFile.readLine(buffer, sizeof(buffer));
    if (linelength < 0)
        return 0;
    QString br_max(buffer);
    maxBrightness = br_max.toInt();

    if (maxBrightness != m_maxBrightness) {
        m_maxBrightness = maxBrightness;
        emit maxBrightnessChanged();
    }

    return m_maxBrightness;
}


int Backlight::getBrightness()
{
    int brightness;

    if (m_backlightOK == false)
        return 0;

    QFile blFile(m_path + "/brightness");

    if (!blFile.open(QIODevice::ReadOnly | QIODevice::Text))
            return 0;
    char buffer[6];
    qint64 linelength = blFile.readLine(buffer, sizeof(buffer));
    if (linelength < 0)
        return 0;
    QString br_max(buffer);
    brightness = br_max.toInt();

    if (brightness != m_brightness) {
        m_brightness = brightness;
        emit brightnessChanged();
    }

    return m_brightness;
}


void Backlight::setBrightness(int brightness)
{
    if (m_backlightOK == false)
        return;

    // restrict brightness to  0 <-> maxBrightness
    if (brightness < 0 || brightness > m_maxBrightness) {
        if (brightness < 0)
            brightness = 0;
        else
            brightness = m_maxBrightness;
    }

    qDebug() << "setting brightness to " << brightness;

    QFile blFile(m_path + "/brightness");

    if (!blFile.open(QIODevice::WriteOnly | QIODevice::Text))
            return;

    blFile.write(QString::number(brightness).toLocal8Bit());
    blFile.close();

    /* read back the real current value */
    getBrightness();
    return;
}


void Backlight::lock()
{
    setBrightness(m_lockBrightness);
    setBLEnable(1);
    return;
}


void Backlight::unlock()
{
    setBrightness(m_unlockBrightness);
    setBLEnable(1);
    return;
}


void Backlight::blank()
{
    setBrightness(0);
    if (m_blankEnable)
        setBLEnable(0);
    else
        setBLEnable(1);
    return;
}


void Backlight::unblank()
{
    setBLEnable(1);
    usleep(100000);
    setBrightness(m_lockBrightness);
    return;
}


void Backlight::setBLEnable(int value)
{
    if (m_backlightOK == false)
        return;

    if (value > 1 || value < 0) {
        return;
    }

    /* invert the value because bl_power is currently inverted */
    if (value == 0)
        value = 1;
    else
        value = 0;

    qDebug() << "set bl_power to " << value;

    QFile bl_powerFile(m_path + "/bl_power");

    if (!bl_powerFile.open(QIODevice::WriteOnly | QIODevice::Text))
            return;

    bl_powerFile.write(QString::number(value).toLocal8Bit());
    bl_powerFile.close();
    return;
}
