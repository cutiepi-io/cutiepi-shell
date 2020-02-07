#!/bin/bash

export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
export QT_QPA_PLATFORM=wayland 
export QT_QPA_EGLFS_KMS_CONFIG=/opt/cutiepi-shell/kms.conf
export QT_WAYLAND_CLIENT_BUFFER_INTEGRATION=wayland-egl 
export XDG_RUNTIME_DIR=$HOME/.xdg
unset QT_IM_MODULE

/opt/qt5/bin/qmlscene web.qml &
