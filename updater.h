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

    void startDownload(const QUrl &url);

    void showError(const QString &message);

    void extractFile(const QString &filePath);

    void setAppDir(const QString &dir);
signals:
    void finished();

private slots:
    void updateProgress(qint64 bytesReceived, qint64 bytesTotal);

private:
    QTextEdit *statusBox;
    QProgressBar *progressBar;
    QNetworkAccessManager *networkManager;
    QString appdir;
};

#endif // UPDATER_H
