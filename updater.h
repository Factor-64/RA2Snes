#ifndef UPDATER_H
#define UPDATER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include "version.h"

class Updater : public QObject {
    Q_OBJECT

public:
    Updater(QObject *parent = nullptr);

    void checkForUpdates();

private slots:
    void onReplyFinished(QNetworkReply *reply);

signals:
    void updateAvailable(const QString &latestVersion);

private:
    QNetworkAccessManager networkManager;
    const QString repository = RA2SNES_REPO_URL;
    const QString currentVersion = RA2SNES_VERSION_STRING;
};

#endif // UPDATER_H
