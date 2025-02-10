#ifndef RACLIENT_H
#define RACLIENT_H

#include <QNetworkReply>
#include <QQueue>

#include "userinfomodel.h"
#include "gameinfomodel.h"
#include "achievementmodel.h"

class RAClient : public QObject {
    Q_OBJECT

public:
    enum RequestType {
        AchievementRequest,
        LeaderboardRequest,
        Nothing
    };

    struct RequestData {
        RequestType type;
        unsigned int id;
        bool hardcore;
        QDateTime unlock_time;
        unsigned int score;
    };

    static RAClient* instance() {
        static RAClient instance;
        return &instance;
    }

    void loginPassword(const QString& username, const QString& password);
    void loginToken(const QString& username, const QString& token);
    void loadGame(const QString& md5hash);
    void getAchievements(unsigned int gameId);
    void getUnlocks();
    void startSession();
    void awardAchievement(unsigned int id, bool hardcore, QDateTime achieved);
    //void getLBPlacements();
    AchievementModel* getAchievementModel();
    QList<LeaderboardInfo> getLeaderboards();
    void queueAchievementRequest(unsigned int id, QDateTime achieved);
    void queueLeaderboardRequest(unsigned int id, QDateTime achieved, unsigned int score);
    void setHardcore(bool h);
    void setConsole(const QString& c, const QUrl& icon);
    bool getHardcore();
    UserInfoModel* getUserInfoModel();
    GameInfoModel* getGameInfoModel();
    void setWidthHeight(int w, int h);
    int getWidth();
    int getHeight();
    void setSaveStates(bool s);
    void setCheats(bool c);
    void setPatched(bool p);
    void setTitle(QString t, QString i, QString l);
    int queueSize();
    void startQueue();
    void stopQueue();
    void runQueue();
    void clearQueue();
    bool isQueueRunning();
    void handleNetworkReply(QNetworkReply *reply);
    bool isGameBeaten();
    bool isGameMastered();
    void clearAchievements();
    void clearGame();
    void clearUser();
    void setAutoHardcore(bool ac);
    bool getAutoHardcore();
    void setAchievementInfo(unsigned int id, AchievementInfoType infotype, int value);
    void setTitleToHash();

signals:
    void loginSuccess();
    void requestFailed(QJsonObject error);
    void requestError(bool net);
    void gotGameID(int gameid);
    void finishedGameSetup();
    void finishedUnlockSetup();
    void awardedAchievement(unsigned int id, QString time, unsigned int points);
    void sessionStarted();
    void requestFinished();
    void continueQueue();

private:
    RAClient(QObject *parent = nullptr);  // Private constructor
    RAClient(const RAClient&) = delete;
    RAClient& operator=(const RAClient&) = delete;

    static const QString baseUrl;
    static const QString userAgent;
    static const QString mediaUrl;
    void sendRequest(const QString& request_type, const QJsonObject& post_content);
    void handleSuccessResponse(const QJsonObject& jsonObject);
    void handleAwardAchievementResponse(const QJsonObject& jsonObject);
    void handleLoginResponse(const QJsonObject& jsonObject);
    void handleGameIDResponse(const QJsonObject& jsonObject);
    void handlePatchResponse(const QJsonObject& jsonObject);
    void handleUnlocksResponse(const QJsonObject& jsonObject);
    void handleStartSessionResponse(const QJsonObject& jsonObject);
    QString latestRequest;
    bool running;
    QNetworkAccessManager* networkManager;
    UserInfoModel* userinfo_model;
    GameInfoModel* gameinfo_model;
    AchievementModel* achievement_model;
    QMap<unsigned int, bool> progressionMap;
    QQueue<RequestData> queue;
    QList<LeaderboardInfo> leaderboards;
};

#endif // RACLIENT_H
