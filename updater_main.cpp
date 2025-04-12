#include <QApplication>
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
        updater.showError("Error: No URL provided. Please provide a URL as a command-line argument.");
    //updater.setAppDir(QCoreApplication::applicationDirPath());
    //updater.startDownload(QUrl("https://github.com/Factor-64/RA2Snes/releases/download/v1.0.0/RA2Snes-windows-x64.zip"));

    return app.exec();
}

