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
#include "FileManagerModel.hpp"
#include "SoftwareManager.hpp"

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
    qmlRegisterType<FileManagerModel>("BNOS.Core", 1, 0, "FileManagerModel");
    qmlRegisterType<SoftwareManager>("BNOS.Core", 1, 0, "SoftwareManager");
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
    engine.addImportPath(appDir + "/../apps");
    engine.addImportPath(appDir + "/../../apps");
    engine.addImportPath("/usr/lib/qt6/qml");
    engine.addImportPath("/usr/share/bnos");

    // Resolve QML entry point across development and installed production paths
    QStringList candidatePaths = {
        appDir + "/../qml/AppWindow.qml",
        appDir + "/../../desktop/qml/AppWindow.qml",
        "/usr/share/bnos/desktop/qml/AppWindow.qml",
        appDir + "/../share/bnos/desktop/qml/AppWindow.qml",
        "desktop/qml/AppWindow.qml"
    };

    QString qmlEntry;
    for (const QString &path : candidatePaths) {
        if (QFile::exists(path)) {
            qmlEntry = path;
            break;
        }
    }

    if (qmlEntry.isEmpty()) {
        std::cerr << "CRITICAL: Could not find AppWindow.qml in any candidate path!" << std::endl;
        return 1;
    }

    std::cout << "Loading BNOS QML Shell from: " << qmlEntry.toStdString() << std::endl;
    engine.load(QUrl::fromLocalFile(qmlEntry));

    if (engine.rootObjects().isEmpty()) {
        std::cerr << "BNOS Shell: No root objects found, checking fallback paths..." << std::endl;
    }

    return app.exec();
}
