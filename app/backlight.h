#ifndef BACKLIGHT_H
#define BACKLIGHT_H

// The Backlight class is constructed the following way:
// There is no statemachine inside Backlight, we only get notified
// about state transistions via signals and act accordingly.
// After creating the Backlight class it does not change anything
// until you call one of the four transition slots.
//
//                             blank()
//            +------------------------------------------------------+
//            |                                                      |
//            |                                                      |
//    +-------+--------------------------+                           v
//    |                                  |       unblank()      +----------------------------------------------------+
//    |  LOCKED                          +<---------------------+                                                    |
//    |  backlight = ON                  |                      |  BLANKED                                           |
//    |  brightness = m_lockBrightness   |                      |  backlight = OFF (if setBlankPowerOff is enabled)  |
//    |                                  |                      |  brightness = m_blankBrightness                    |
//    +-+--------------+-----------------+                      |                                                    |
//      |              ^                                        +----------------------------------------------------+
//      |              |
//      |              | lock()
//      | unlock()     |
//      |              |
//      |      +-------+---------------------------+
//      +----->+                                   |
//             |  UNLOCKED                         |
//             |  backlight = ON                   |
//             |  brightness = m_unlockBrightness  |
//             |                                   |
//             +-----------------------------------+

#define QT_NO_DEBUG_OUTPUT 1

#include <QObject>
#include <QDir>
#include <QFile>
#include <QDebug>
#include <unistd.h>

class Backlight : public QObject
{
    Q_OBJECT
    Q_PROPERTY( int brightness READ getBrightness WRITE setBrightness NOTIFY brightnessChanged FINAL )

    // We don't want to be able to change the maxBrightness from QML, hence the read only maxBrightness
    // Further, notice that maxBrightness is not an instance variable.
    Q_PROPERTY( int maxBrightness READ getMaxBrightness NOTIFY maxBrightnessChanged FINAL )

public:
    explicit Backlight();

    int  getBrightness();
    void setBrightness(int brightness);
    int  getMaxBrightness();

    void setLockBrightness(int brightness);
    void setUnlockBrightness(int brightness);
    void setBlankBrightness(int brightness);
    void setBlankPowerOff(bool enable);

public slots:
    void lock();
    void unlock();
    void blank();
    void unblank();

signals:
    void brightnessChanged();
    void maxBrightnessChanged();

private:
    int m_maxBrightness;
    int m_brightness;
    int m_blankBrightness;
    int m_lockBrightness;
    int m_unlockBrightness;
    bool m_blankEnable;
    QString m_path;
    bool m_backlightOK;

    void setBLEnable(int value);
};


#endif // BACKLIGHT_H

