#include "updater.h"
#include <QVBoxLayout>
#include <QProcess>
#include <QFileInfo>
#include <QDir>
#include <QTimer>
#include <QThreadPool>
#include "miniz/miniz.h"

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

    progressBar->setFormat("Downloading...");
    progressBar->setValue(0);
    statusBox->append("Starting download: " + url.toString());

    connect(reply, &QNetworkReply::downloadProgress, this, &Updater::updateProgress);

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        if (reply->error() == QNetworkReply::NoError) {
            QFile file("latest_release.zip");
            if (file.open(QIODevice::WriteOnly)) {
                file.write(reply->readAll());
                file.close();
                statusBox->append("Download completed!");
                extractFile(appdir + QDir::separator() +"latest_release.zip");
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
        progressBar->setFormat("Downloading... %p%");
        statusBox->append(QString("Downloaded %1 of %2 bytes").arg(bytesReceived).arg(bytesTotal));
    }
}

void Updater::extractFile(const QString &filePath) {
    progressBar->setFormat("Extracting...");
    progressBar->setValue(0);
    QThreadPool::globalInstance()->start([this, filePath]() {
        const QString outputDir = appdir;
        mz_zip_archive zip_archive;
        memset(&zip_archive, 0, sizeof(zip_archive));

        QMetaObject::invokeMethod(statusBox, [this, outputDir]() {
            statusBox->append(QString("Extracting to: %1").arg(outputDir));
        }, Qt::QueuedConnection);

        if (!mz_zip_reader_init_file(&zip_archive, filePath.toStdString().c_str(), 0)) {
            QMetaObject::invokeMethod(statusBox, [this]() {
                statusBox->append("Error: Failed to open ZIP file!");
            }, Qt::QueuedConnection);
            return;
        }

        const int fileCount = mz_zip_reader_get_num_files(&zip_archive);
        for (int i = 0; i < fileCount; i++) {
            mz_zip_archive_file_stat file_stat;
            if (!mz_zip_reader_file_stat(&zip_archive, i, &file_stat)) {
                QMetaObject::invokeMethod(statusBox, [this]() {
                    statusBox->append("Error: Failed to get file info!");
                }, Qt::QueuedConnection);
                continue;
            }
            QString outputFilePath = outputDir + QDir::separator() + file_stat.m_filename;

            QFileInfo fileInfo(outputFilePath);
            QDir().mkpath(fileInfo.path());

            QFile::remove(outputFilePath);
            if(file_stat.m_filename[strlen(file_stat.m_filename) - 1] != '/')
            {
                if (!mz_zip_reader_extract_to_file(&zip_archive, i, outputFilePath.toStdString().c_str(), 0)) {
                    QMetaObject::invokeMethod(statusBox, [this, &file_stat]() {
                        statusBox->append(QString("Error: Failed to extract file: %1").arg(file_stat.m_filename));
                    }, Qt::QueuedConnection);
                } else {
                    QMetaObject::invokeMethod(statusBox, [this, &file_stat]() {
                        statusBox->append(QString("Extracted: %1").arg(file_stat.m_filename));
                    }, Qt::QueuedConnection);
                }
            }

            const int extractionProgress = ((i + 1) * 100) / fileCount;
            QMetaObject::invokeMethod(progressBar, [this, extractionProgress]() {
                progressBar->setValue(extractionProgress);
                progressBar->setFormat("Extracting... %p%");
            }, Qt::QueuedConnection);
        }

        mz_zip_reader_end(&zip_archive);
        QMetaObject::invokeMethod(statusBox, [this]() {
            statusBox->append("Extraction completed successfully!");
            statusBox->append("Launching RA2SNES...");
        }, Qt::QueuedConnection);
        QFile::remove(appdir + QDir::separator() + "latest_release.zip");

        QProcess::startDetached(appdir + QDir::separator() + "ra2snes.exe", QStringList());
        QTimer::singleShot(2000, this, [=]() {
            emit finished();
        });
    });
}

void Updater::setAppDir(const QString &dir)
{
    appdir = dir;
}

void Updater::showError(const QString &message) {
    statusBox->append(message);
}
