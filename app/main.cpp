/* 
    Copyright (C) 2021 Penk Chen

    This file is part of CutiePi shell of the CutiePi project.

    CutiePi shell is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    CutiePi shell is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with CutiePi shell.  If not, see <https://www.gnu.org/licenses/>.
*/

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QtWebEngine/qtwebengineglobal.h>
#include <QtWebEngine/qquickwebengineprofile.h>
#include <QtWebEngineCore/qwebengineurlrequestinterceptor.h>
#include <QDebug>
#include <QThread>
#include <QFile>
#include <QCursor>
#include "backlight.h"

#ifdef USE_ADBLOCK
#include "third_party/ad-block/ad_block_client.h"

class RequestInterceptor : public QWebEngineUrlRequestInterceptor
{
    Q_OBJECT
public:
    RequestInterceptor(QObject *parent = nullptr) : QWebEngineUrlRequestInterceptor(parent)
    {
        QThread *thread = QThread::create([this]{
            QFile file("/opt/cutiepi-shell/easylist.txt");
            QString easyListTxt;

            if(!file.exists()) {
                qDebug() << "No easylist.txt file found.";
            } else {
                if (file.open(QIODevice::ReadOnly | QIODevice::Text)){
                    easyListTxt = file.readAll();
                }
                file.close();
                client.parse(easyListTxt.toStdString().c_str());
            }
        });
        thread->start();
    }

    void interceptRequest(QWebEngineUrlRequestInfo &info)
    {
        if (client.matches(info.requestUrl().toString().toStdString().c_str(), 
            FONoFilterOption, info.requestUrl().host().toStdString().c_str())) {
                //qDebug() << "Blocked: " << info.requestUrl();
                info.block(true);
        }
    }

private: 
    AdBlockClient client;
};
#endif 

int main(int argc, char *argv[])
{
    qputenv("QT_QPA_PLATFORM", "xcb");
    qputenv("DISPLAY", ":0.0");
    qputenv("QT_IM_MODULE", "qtvirtualkeyboard");
    qputenv("QT_XCB_GL_INTEGRATION", "xcb_egl");
    qputenv("QT_IM_MODULE", "qtvirtualkeyboard");

    qputenv("XDG_RUNTIME_DIR", "/run/user/1000");
    qputenv("DBUS_SESSION_BUS_ADDRESS", "unix:path=/run/user/1000/bus");

    QtWebEngine::initialize();
    QGuiApplication app(argc, argv);
    QGuiApplication::setOverrideCursor(QCursor(Qt::BlankCursor));
    app.setOrganizationName("CutiePi");
    app.setOrganizationDomain("cutiepi.io");
    app.setApplicationName("Shell");

    QQmlApplicationEngine engine;

    Backlight backlight;
    engine.rootContext()->setContextProperty("backlight", &backlight); 

#ifdef USE_ADBLOCK
    RequestInterceptor interceptor;
    QQuickWebEngineProfile adblockProfile;
    adblockProfile.setUrlRequestInterceptor(&interceptor);
    adblockProfile.setHttpUserAgent("Mozilla/5.0 (X11; CrOS armv7l 10895.56.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.102 Safari/537.36");
    adblockProfile.setStorageName("Profile");
    adblockProfile.setOffTheRecord(false);
    engine.rootContext()->setContextProperty("adblockProfile", &adblockProfile);
#endif

    engine.load("file:///opt/cutiepi-shell/shell.qml");
    return app.exec();
}

#include "main.moc"