#include "updater.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QVersionNumber>
#include <QDebug>

Updater::Updater(QObject *parent)
    : QObject(parent) {
    connect(&networkManager, &QNetworkAccessManager::finished, this, &Updater::onReplyFinished);
}

void Updater::checkForUpdates() {
    QUrl apiUrl(QString("https://api.github.com/repos/%1/releases/latest").arg(repository));
    QNetworkRequest request(apiUrl);
    networkManager.get(request);
}

void Updater::onReplyFinished(QNetworkReply *reply) {
    if (reply->error() == QNetworkReply::NoError) {
        QJsonDocument jsonDoc = QJsonDocument::fromJson(reply->readAll());
        QJsonObject jsonObj = jsonDoc.object();
        QString latestVersion = jsonObj["tag_name"].toString().mid(1);
        if (QVersionNumber::fromString(latestVersion) > QVersionNumber::fromString(currentVersion)) {
            emit updateAvailable(latestVersion);
        }
    }
    reply->deleteLater();
}
