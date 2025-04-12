#ifndef UPDATER_H
#define UPDATER_H

#include <QWidget>
#include <QTextEdit>
#include <QProgressBar>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QFile>
#include <QString>

class Updater : public QWidget {
    Q_OBJECT
public:
    explicit Updater(QWidget *parent = nullptr);

    // Starts the download process with the given URL
    void startDownload(const QUrl &url);

    // Shows error messages in the status box
    void showError(const QString &message);

    // Extracts the given ZIP file
    void extractFile(const QString &filePath);

    void setAppDir(const QString &dir);
signals:
    void finished();

private slots:
    // Updates the progress bar based on download progress
    void updateProgress(qint64 bytesReceived, qint64 bytesTotal);

private:
    QTextEdit *statusBox;               // Displays status messages
    QProgressBar *progressBar;          // Shows progress (download/extraction)
    QNetworkAccessManager *networkManager; // Manages network requests
    QString appdir;
};

#endif // UPDATER_H
