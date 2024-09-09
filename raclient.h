#ifndef RACLIENT_H
#define RACLIENT_H

#include <QObject>
#include <QByteArray>
#include <QList>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDebug>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include "rastructs.h"

class RAClient : public QObject {
    Q_OBJECT

public:
    explicit RAClient(QObject *parent = nullptr);

    void loginPassword(const QString username, const QString password);
    void loginToken(const QString username, const QString token);
    void loadGame(const QString md5hash);
    void getAchievements(const unsigned int gameId);
    void getUnlocks();
    void startSession();
    void awardAchievement(unsigned int id);
    //void getLBPlacements();
    QList<AchievementInfo> getAchievements();
    QList<LeaderboardInfo> getLeaderboards();
    void queueAchievementRequest(unsigned int id);
    void queueLeaderboardRequest(unsigned int id, unsigned int score);
    void runQueue();
    void setHardcore(bool h);

signals:
    void loginFailed();
    void loginSuccess();
    void requestFailed();
    void requestError();
    void gotGameID(int gameid);
    void finishedGameSetup();
    void finishedUnlockSetup();
    void awardedAchievement();
    void gameLoadFailed();
    //void stateChanged();

private:
    static const QString baseUrl;
    static const QString userAgent;
    static const QString mediaUrl;
    void request(const QString request_type, const QList<QPair<QString, QString>> post_content);
    void handleNetworkReply(QNetworkReply *reply);
    //void changeState(State s);
    //State state;
    QString latestRequest;
    bool ready;
    QNetworkAccessManager *manager;
    UserInfo userinfo;
    GameInfo gameinfo;
    QList<unsigned int> unlocks;
    QList<QPair<unsigned int, unsigned int>> lb_placement;
    QList<QJsonObject> queue;
    bool hardcore;
};

#endif // RACLIENT_H
