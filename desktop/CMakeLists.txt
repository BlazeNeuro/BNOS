cmake_minimum_required(VERSION 3.16)
project(bnos-shell VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 6.4 REQUIRED COMPONENTS Core Gui Quick Qml DBus)

set(SOURCES
    src/main.cpp
    src/models/AppModel.hpp
    src/models/AppModel.cpp
    src/services/SystemManager.hpp
    src/services/SystemManager.cpp
    src/services/PowerManager.hpp
    src/services/PowerManager.cpp
    src/services/NetworkManager.hpp
    src/services/NetworkManager.cpp
    src/services/AudioController.hpp
    src/services/AudioController.cpp
    ../apps/bnos-files/src/models/FileManagerModel.hpp
    ../apps/bnos-files/src/models/FileManagerModel.cpp
    ../apps/bnos-store/src/services/SoftwareManager.hpp
    ../apps/bnos-store/src/services/SoftwareManager.cpp
)

qt_add_executable(bnos-shell ${SOURCES})

target_include_directories(bnos-shell PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_SOURCE_DIR}/src/models
    ${CMAKE_CURRENT_SOURCE_DIR}/src/services
    ${CMAKE_CURRENT_SOURCE_DIR}/../apps/bnos-files/src/models
    ${CMAKE_CURRENT_SOURCE_DIR}/../apps/bnos-store/src/services
)

target_link_libraries(bnos-shell PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    Qt6::Qml
    Qt6::DBus
)

install(TARGETS bnos-shell DESTINATION bin)
