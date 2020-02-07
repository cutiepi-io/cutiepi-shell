/*
    Copyright (C) 2019-2020 Ping-Hsun "penk" Chen
    Copyright (C) 2020 Chouaib Hamrouche
    Contact: hello@cutiepi.io
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
    along with CutiePi shell. If not, see <https://www.gnu.org/licenses/>.
*/

import QtQuick 2.14
import QtWayland.Compositor 1.14

WaylandCompositor {
    Screen { id: screen }
    WlShell {
        onWlShellSurfaceCreated: {
            screen.handleShellSurface(shellSurface)
        }
    }
    ListModel { id: shellSurfaces }
    TextInputManager {}
}