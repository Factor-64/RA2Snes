#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "ra2snes.h"
#include "achievementmodel.h"
#include "gameinfomodel.h"
#include "userinfomodel.h"
#include "achievementsortfilterproxymodel.h"

int main(int argc, char *argv[])
{
    QGuiApplication::setHighDpiScaleFactorRoundingPolicy(Qt::HighDpiScaleFactorRoundingPolicy::PassThrough);
    QGuiApplication app(argc, argv);

    qmlRegisterType<AchievementSortFilterProxyModel>("CustomModels", 1, 0, "AchievementSortFilterProxyModel");

    // Register singletons as non-creatable
    qmlRegisterSingletonInstance("CustomModels", 1, 0, "Ra2snes", ra2snes::instance());
    qmlRegisterSingletonInstance("CustomModels", 1, 0, "AchievementModel", AchievementModel::instance());
    qmlRegisterSingletonInstance("CustomModels", 1, 0, "GameInfoModel", GameInfoModel::instance());
    qmlRegisterSingletonInstance("CustomModels", 1, 0, "UserInfoModel", UserInfoModel::instance());

    ra2snes::instance()->setAppDirPath(QCoreApplication::applicationDirPath());

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/ui/login.qml")));

    QObject::connect(ra2snes::instance(), &ra2snes::loginSuccess, &engine, [&engine]() {
        const auto rootObjects = engine.rootObjects();
        QObject *loginWindow = nullptr;

        if (!rootObjects.isEmpty()) {
            loginWindow = rootObjects.first();
        }
        if (loginWindow)
            loginWindow->deleteLater();
        engine.load(QUrl(QStringLiteral("qrc:/ui/mainwindow.qml")));
        engine.clearComponentCache();
    });

    QObject::connect(ra2snes::instance(), &ra2snes::signedOut, &engine, [&engine]() {
        const auto rootObjects = engine.rootObjects();
        QObject *mainWindow = nullptr;

        if (!rootObjects.isEmpty()) {
            mainWindow = rootObjects.first();
        }
        if (mainWindow)
            mainWindow->deleteLater();
        engine.load(QUrl(QStringLiteral("qrc:/ui/login.qml")));
        engine.clearComponentCache();
    });

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
