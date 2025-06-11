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
    void getAchievements(const unsigned int& gameId);
    void getUnlocks();
    void startSession();
    void awardAchievement(const unsigned int& id, const bool& hardcore, const QDateTime& achieved);
    //void getLBPlacements();
    AchievementModel* getAchievementModel();
    UserInfoModel* getUserInfoModel();
    QList<LeaderboardInfo> getLeaderboards();
    void queueAchievementRequest(const unsigned int& id, const QDateTime& achieved);
    //void queueLeaderboardRequest(const unsigned int& id, const QDateTime& achieved, const unsigned int& score);
    void setHardcore(const bool& h);
    void setConsole(const QString& c, const QUrl& icon);
    bool getHardcore();
    void setSaveStates(const bool& s);
    void setCheats(const bool& c);
    void setPatched(const bool& p);
    void setInGameHooks(const bool& n);
    void setTitle(const QString& t, const QString& i, const QString& l);
    void clearQueue();
    void handleNetworkReply(QNetworkReply *reply);
    bool isGameBeaten();
    bool isGameMastered();
    void clearAchievements();
    void clearGame();
    void clearUser();
    void setAutoHardcore(const bool& ac);
    bool getAutoHardcore();
    void setAchievementInfo(const unsigned int& id, const AchievementInfoType& infotype, const int& value);
    void setTitleToHash(const QString& currentGame);
    void setHash(const QString& h);
    void refresh();

signals:
    void loginSuccess(bool& r);
    void requestFailed(QJsonObject error);
    void requestError(const bool& net);
    void gotGameID(const int& gameid);
    void finishedGameSetup();
    void finishedUnlockSetup();
    void awardedAchievement(const unsigned int& id, const QString& time, const unsigned int& points);
    void sessionStarted();
    void requestFinished();
    void continueQueue();

private:
    RAClient(QObject *parent = nullptr);
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
    void runQueue();
    QString latestRequest;
    bool warning;
    bool m_refresh;
    QNetworkAccessManager* networkManager;
    UserInfoModel* userinfo_model;
    GameInfoModel* gameinfo_model;
    AchievementModel* achievement_model;
    QMap<unsigned int, bool> progressionMap;
    QMap<unsigned int, bool> winMap;
    QQueue<RequestData> queue;
    QList<LeaderboardInfo> leaderboards;
};

#endif // RACLIENT_H
