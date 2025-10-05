#include "networkcachemanager.h"
#include <QNetworkDiskCache>
#include <QStandardPaths>
#include <QNetworkAccessManager>
#include <QDir>
//#include <QDebug>

NetworkCacheManager::NetworkCacheManager(const QString &appDirPath)
    : m_appDirPath(appDirPath)
{
}

QNetworkAccessManager *NetworkCacheManager::create(QObject *parent) {
    QNetworkAccessManager *manager = new QNetworkAccessManager(parent);

    QString cacheDir = m_appDirPath + QDir::separator() + "cache";

    QDir dir;

    if (!dir.exists(cacheDir))
        dir.mkpath(cacheDir);

    QNetworkDiskCache *diskCache = new QNetworkDiskCache(manager);
    diskCache->setCacheDirectory(cacheDir);
    diskCache->setMaximumCacheSize(20 * 1024 * 1024); // 20 MB
    manager->setCache(diskCache);

    return manager;
}
