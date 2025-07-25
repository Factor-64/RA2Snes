#ifndef RACLIENT_H
#define RACLIENT_H

#include <QNetworkReply>
#include <QJsonObject>
#include <QQueue>
#include "userinfomodel.h"
#include "gameinfomodel.h"
#include "achievementmodel.h"

class RAClient : public QObject {
    Q_OBJECT

public:
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
    void awardAchievement(const unsigned int& id, const QDateTime& achieved);
    //void getLBPlacements();
    AchievementModel* getAchievementModel();
    UserInfoModel* getUserInfoModel();
    QList<LeaderboardInfo> getLeaderboards();
    void setHardcore(const bool& h);
    void setConsole(const QString& c, const QUrl& icon);
    bool getHardcore();
    void setSaveStates(const bool& s);
    void setCheats(const bool& c);
    void setPatched(const bool& p);
    void setInGameHooks(const bool& n);
    void setTitle(const QString& t, const QString& i, const QString& l);
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
    QString getRichPresence();
    void ping(const QString& rp);
    bool sendQueuedRequest();

signals:
    void loginSuccess(bool r);
    void requestFailed(QJsonObject error);
    void requestError(const bool& net, const QString& request, const QString& error);
    void gotGameID(const int& gameid);
    void finishedGameSetup();
    void finishedUnlockSetup();
    void awardedAchievement(const unsigned int& id, const QString& time, const unsigned int& points);
    void sessionStarted();
    void requestFinished();

private:
    RAClient(QObject *parent = nullptr);
    RAClient(const RAClient&) = delete;
    RAClient& operator=(const RAClient&) = delete;
    ~RAClient();

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
    void handlePingResponse(const QJsonObject& jsonObject);
    QString latestRequest;
    bool warning;
    bool m_refresh;
    QNetworkAccessManager* networkManager;
    UserInfoModel* userinfo_model;
    GameInfoModel* gameinfo_model;
    AchievementModel* achievement_model;
    QMap<unsigned int, bool> progressionMap;
    QMap<unsigned int, bool> winMap;
    QMap<unsigned int, QDateTime> achievedTimes;
    QList<LeaderboardInfo> leaderboards;
    QQueue<QPair<QString, QJsonObject>> queue;
    QJsonObject latestPost;
    bool running;
};

#endif // RACLIENT_H
