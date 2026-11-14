cmake_minimum_required(VERSION 3.16)
project(bnos-shell VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 6.4 REQUIRED COMPONENTS Core Gui Quick Qml)

set(SOURCES
    src/main.cpp
)

set(QML_FILES
    qml/AppWindow.qml
    qml/Shell.qml
    qml/panel/Panel.qml
    qml/launcher/Launcher.qml
    qml/controlcenter/ControlCenter.qml
    qml/notifications/NotificationCenter.qml
    qml/lockscreen/LockScreen.qml
    qml/settings/SettingsApp.qml
)

qt_add_executable(bnos-shell ${SOURCES})

target_link_libraries(bnos-shell PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    Qt6::Qml
)

install(TARGETS bnos-shell DESTINATION bin)
