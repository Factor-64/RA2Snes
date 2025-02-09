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

    // Register singletons
    qmlRegisterSingletonType<ra2snes>("CustomModels", 1, 0, "Ra2snes",
                                      [](QQmlEngine*, QJSEngine*) -> QObject* {
                                          return ra2snes::instance();
                                      });

    qmlRegisterSingletonType<AchievementModel>("CustomModels", 1, 0, "AchievementModel",
                                               [](QQmlEngine*, QJSEngine*) -> QObject* {
                                                   return AchievementModel::instance();
                                               });

    qmlRegisterSingletonType<GameInfoModel>("CustomModels", 1, 0, "GameInfoModel",
                                            [](QQmlEngine*, QJSEngine*) -> QObject* {
                                                return GameInfoModel::instance();
                                            });

    qmlRegisterSingletonType<UserInfoModel>("CustomModels", 1, 0, "UserInfoModel",
                                            [](QQmlEngine*, QJSEngine*) -> QObject* {
                                                return UserInfoModel::instance();
                                            });

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("appDirPath", QCoreApplication::applicationDirPath());
    engine.load(QUrl(QStringLiteral("qrc:/ui/login.qml")));

    QObject::connect(ra2snes::instance(), &ra2snes::loginSuccess, &engine, [&engine]() {
        const auto rootObjects = engine.rootObjects();
        QObject *loginWindow = nullptr;

        if (!rootObjects.isEmpty()) {
            loginWindow = rootObjects.first();
        }
        if(loginWindow)
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
        if(mainWindow)
            mainWindow->deleteLater();
        engine.load(QUrl(QStringLiteral("qrc:/ui/login.qml")));
        engine.clearComponentCache();
    });

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
