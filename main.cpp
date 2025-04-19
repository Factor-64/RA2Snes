#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "ra2snes.h"
#include "achievementmodel.h"
#include "gameinfomodel.h"
#include "userinfomodel.h"
#include "achievementsortfilterproxymodel.h"

void loadQml(QQmlApplicationEngine &engine, const QString &url) {
    const auto rootObjects = engine.rootObjects();
    QObject *window = nullptr;
    if (!rootObjects.isEmpty())
        window = rootObjects.first();
    if (window)
        window->deleteLater();
    engine.clearComponentCache();
    engine.load(QUrl(url));
}

int main(int argc, char *argv[]) {
    QGuiApplication::setHighDpiScaleFactorRoundingPolicy(Qt::HighDpiScaleFactorRoundingPolicy::PassThrough);
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    qmlRegisterType<AchievementSortFilterProxyModel>("CustomModels", 1, 0, "AchievementSortFilterProxyModel");
    qmlRegisterSingletonInstance("CustomModels", 1, 0, "Ra2snes", ra2snes::instance());
    qmlRegisterSingletonInstance("CustomModels", 1, 0, "AchievementModel", AchievementModel::instance());
    qmlRegisterSingletonInstance("CustomModels", 1, 0, "GameInfoModel", GameInfoModel::instance());
    qmlRegisterSingletonInstance("CustomModels", 1, 0, "UserInfoModel", UserInfoModel::instance());
    ra2snes::instance()->setAppDirPath(QCoreApplication::applicationDirPath());

    QObject::connect(ra2snes::instance(), &ra2snes::loginSuccess, &engine, [&engine]() {
        //qDebug() << "Loggedin";
        loadQml(engine, "qrc:/ui/mainwindow.qml");
    });

    QObject::connect(ra2snes::instance(), &ra2snes::signedOut, &engine, [&engine]() {
        loadQml(engine, "qrc:/ui/login.qml");
    });

    return app.exec();
}
