#include "updater.h"
#include <QVBoxLayout>
#include <QProcess>
#include <QFileInfo>
#include <QDir>
#include <QTimer>

Updater::Updater(QWidget *parent)
    : QWidget(parent),
    statusBox(new QTextEdit(this)),
    progressBar(new QProgressBar(this)),
    networkManager(new QNetworkAccessManager(this)) {

    QVBoxLayout *layout = new QVBoxLayout(this);

    statusBox->setReadOnly(true);
    layout->addWidget(statusBox);

    progressBar->setValue(0);

    layout->addWidget(progressBar);

    resize(300, 100);
}

void Updater::startDownload(const QUrl &url) {
    QNetworkRequest request(url);
    QNetworkReply *reply = networkManager->get(request);

    statusBox->append("Starting download: " + url.toString());

    connect(reply, &QNetworkReply::downloadProgress, this, &Updater::updateProgress);

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        if (reply->error() == QNetworkReply::NoError) {
            QFile file("latest_release.zip");
            if (file.open(QIODevice::WriteOnly)) {
                file.write(reply->readAll());
                file.close();
                statusBox->append("Download completed!");
                extractFile(appdir + "/latest_release.zip");
            }
        } else {
            statusBox->append("Error: " + reply->errorString());
        }
        reply->deleteLater();
    });

    connect(reply, &QNetworkReply::errorOccurred, this, [this](QNetworkReply::NetworkError error) {
        statusBox->append("Network Error: " + QString::number(error));
    });
}

void Updater::updateProgress(qint64 bytesReceived, qint64 bytesTotal) {
    if (bytesTotal > 0) {
        progressBar->setValue(static_cast<int>((bytesReceived * 100) / bytesTotal));
        statusBox->append(QString("Downloaded %1 of %2 bytes").arg(bytesReceived).arg(bytesTotal));
    }
}

void Updater::extractFile(const QString &filePath) {
    QString outputDir = appdir;

    statusBox->append("Extracting Update...");
#ifdef Q_OS_WIN
    QString powershellScript = QString(
                                   "Expand-Archive -LiteralPath '%1' -DestinationPath '%2' -Force"
                                   ).arg(QDir::toNativeSeparators(filePath), QDir::toNativeSeparators(outputDir));

    QProcess *process = new QProcess(this);
    process->start("powershell", QStringList() << "-Command" << powershellScript);

    connect(process, &QProcess::finished, this, [this, process](int exitCode) {
        if (exitCode == 0) {
            statusBox->append("Extraction completed successfully!");
            statusBox->append("Launching RA2SNES...");
            QFile::remove(appdir + "latest_release.zip");
            QProcess::startDetached(appdir + "/ra2snes.exe", QStringList());
            QTimer::singleShot(2000, this, [=]() {
                 emit finished();
            });
        } else {
            statusBox->append("Error: Extraction failed!");
            statusBox->append("Extract latest_release.zip Manually.");
        }
        process->deleteLater();
    });

#elif defined(Q_OS_LINUX) || defined(Q_OS_MACOS)
    QProcess *process = new QProcess(this);
    process->start("unzip", QStringList() << "-o" << filePath << "-d" << outputDir);

    connect(process, &QProcess::finished, this, [this, process](int exitCode) {
        if (exitCode == 0) {
            statusBox->append("Extraction completed successfully!");
            QFile::remove(appdir + "latest_release.zip");
            QProcess::startDetached(appdir + "/ra2snes", QStringList());
        } else {
            statusBox->append("Error: Extraction failed!");
            statusBox->append("Extract latest_release.zip Manually.");
        }
        process->deleteLater();
    });

#else
    statusBox->append("Error: Extraction is not supported on this platform.");
#endif
}

void Updater::setAppDir(const QString &dir)
{
    appdir = dir;
}

void Updater::showError(const QString &message) {
    statusBox->append(message);
}
