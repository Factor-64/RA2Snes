#include <QApplication>
#include <QTimer>
#include "updater.h"

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);

    Updater updater;
    updater.show();

    if (argc > 1)
    {
        QObject::connect(&updater, &Updater::finished, [&]() {
            QCoreApplication::quit();
        });
        QUrl url(argv[1]);
        updater.setAppDir(QCoreApplication::applicationDirPath());
        updater.startDownload(url);
    }
    else
    {
        updater.showError("Error: No URL provided. Please provide a URL as a command-line argument.");
        QTimer::singleShot(2000, &app, [=]() {
            QCoreApplication::quit();
        });
    }

    return app.exec();
}

