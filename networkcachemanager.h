#ifndef NETWORKCACHEMANAGER_H
#define NETWORKCACHEMANAGER_H

#include <QQmlNetworkAccessManagerFactory>

class NetworkCacheManager : public QQmlNetworkAccessManagerFactory {
public:
    explicit NetworkCacheManager(const QString &appDirPath);
    QNetworkAccessManager *create(QObject *parent) override;

private:
    QString m_appDirPath;
};

#endif // NETWORKCACHEMANAGER_H
