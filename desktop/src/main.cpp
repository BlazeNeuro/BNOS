#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QDir>
#include <QIcon>
#include <iostream>

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

    QQmlApplicationEngine engine;

    // Add import paths for QML modules (BNOS.UI)
    QString appDir = QCoreApplication::applicationDirPath();
    engine.addImportPath(appDir + "/../design-system");
    engine.addImportPath(appDir + "/../../design-system");
    engine.addImportPath("/usr/lib/qt6/qml");

    const QUrl url(u"qrc:/qml/AppWindow.qml"_s);

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl) {
            std::cerr << "BNOS Shell: Failed to load QML root object." << std::endl;
            QCoreApplication::exit(-1);
        }
    }, Qt::QueuedConnection);

    // Support loading directly from filesystem if QRC not used in dev mode
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
