#!/bin/bash

export QT_QPA_PLATFORM=eglfs
export QT_IM_MODULE=qtvirtualkeyboard
export QT_VIRTUALKEYBOARD_LAYOUT_PATH=/opt/cutiepi-shell/layouts/
export QT_QPA_EGLFS_KMS_CONFIG=/opt/cutiepi-shell/kms.conf

if [ ! "`systemctl is-active connman`" == "active" ]; then 
    sudo service connman start 
fi

rfkill unblock all
connmanctl disable wifi
connmanctl enable wifi 

/opt/qt5/bin/qmlscene /opt/cutiepi-shell/shell.qml
