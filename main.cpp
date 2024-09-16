#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "ra2snes.h"
#include "achievementsortfilterproxymodel.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    qmlRegisterType<AchievementModel>("CustomModels", 1, 0, "AchievementModel");
    qmlRegisterType<AchievementSortFilterProxyModel>("CustomModels", 1, 0, "AchievementSortFilterProxyModel");

    QQmlApplicationEngine engine;
    ra2snes ra2snesInstance;

    engine.rootContext()->setContextProperty("ra2snes", &ra2snesInstance);
    engine.rootContext()->setContextProperty("achievementModel", ra2snesInstance.achievementModel());
    engine.load(QUrl(QStringLiteral("qrc:/ui/login.qml")));

    const auto rootObjects = engine.rootObjects();
    QObject *loginWindow = nullptr;

    if (!rootObjects.isEmpty()) {
        loginWindow = rootObjects.first();
    }
    QObject::connect(&ra2snesInstance, &ra2snes::loginSuccess, &engine, [&loginWindow, &engine]() {
        if(loginWindow)
            loginWindow->deleteLater();
        engine.load(QUrl(QStringLiteral("qrc:/ui/mainwindow.qml")));
        engine.clearComponentCache();
    });

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
