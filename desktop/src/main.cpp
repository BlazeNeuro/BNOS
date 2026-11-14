#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QDir>
#include <QIcon>
#include <iostream>

#include "models/AppModel.hpp"
#include "services/SystemManager.hpp"
#include "services/PowerManager.hpp"
#include "services/NetworkManager.hpp"
#include "services/AudioController.hpp"

int main(int argc, char *argv[])
{
    // Configure default high-DPI scaling for crisp shadcn/ui borders
    QGuiApplication::setHighDpiScaleFactorRoundingPolicy(
        Qt::HighDpiScaleFactorRoundingPolicy::PassThrough);

    QGuiApplication app(argc, argv);

    app.setApplicationName("bnos-shell");
    app.setApplicationDisplayName("BNOS Desktop Shell");
    app.setOrganizationName("BlazeNeuro");
    app.setOrganizationDomain("blazeneuro.com");
    app.setApplicationVersion("1.0.0");

    // Initialize C++ Backend Services
    SystemManager systemManager;
    PowerManager powerManager;
    NetworkManager networkManager;
    AudioController audioController;

    // Register QML types in BNOS.Core
    qmlRegisterType<AppModel>("BNOS.Core", 1, 0, "AppModel");
    qmlRegisterSingletonInstance("BNOS.Core", 1, 0, "SystemManager", &systemManager);
    qmlRegisterSingletonInstance("BNOS.Core", 1, 0, "PowerManager", &powerManager);
    qmlRegisterSingletonInstance("BNOS.Core", 1, 0, "NetworkManager", &networkManager);
    qmlRegisterSingletonInstance("BNOS.Core", 1, 0, "AudioController", &audioController);

    QQmlApplicationEngine engine;

    // Expose as context properties for convenient global access in QML
    engine.rootContext()->setContextProperty("SystemManager", &systemManager);
    engine.rootContext()->setContextProperty("PowerManager", &powerManager);
    engine.rootContext()->setContextProperty("NetworkManager", &networkManager);
    engine.rootContext()->setContextProperty("AudioController", &audioController);

    // Add import paths for QML modules (BNOS.UI)
    QString appDir = QCoreApplication::applicationDirPath();
    engine.addImportPath(appDir + "/../design-system");
    engine.addImportPath(appDir + "/../../design-system");
    engine.addImportPath("/usr/lib/qt6/qml");

    // Support loading directly from filesystem in dev mode
    QString localQmlPath = appDir + "/../qml/AppWindow.qml";
    if (QFile::exists(localQmlPath)) {
        engine.load(QUrl::fromLocalFile(localQmlPath));
    } else {
        engine.load(QUrl::fromLocalFile("desktop/qml/AppWindow.qml"));
    }

    if (engine.rootObjects().isEmpty()) {
        std::cerr << "BNOS Shell: No root objects found, checking fallback paths..." << std::endl;
    }

    return app.exec();
}
