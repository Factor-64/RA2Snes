#include "raclient.h"
#include <QUrlQuery>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include "rc_version.h"
#include "version.h"

const QString RAClient::baseUrl = "https://retroachievements.org/";
const QString RAClient::mediaUrl = "https://media.retroachievements.org/";
const QString RAClient::userAgent = QString("ra2snes/%1 rcheevos/%2").arg(RA2SNES_VERSION_STRING,RCHEEVOS_VERSION_STRING);

RAClient::RAClient(QObject *parent)
    : QObject(parent)
{
    networkManager = new QNetworkAccessManager(this);
    userinfo_model = UserInfoModel::instance();
    gameinfo_model = GameInfoModel::instance();
    achievement_model = AchievementModel::instance();
    connect(networkManager, &QNetworkAccessManager::finished, this, &RAClient::handleNetworkReply);
    warning = false;
    m_refresh = false;
    running = false;
}

void RAClient::loginPassword(const QString& username, const QString& password)
{
    m_refresh = false;
    QJsonObject post_content;
    post_content["u"] = username;
    post_content["p"] = password;

    sendRequest("login", post_content);
}

void RAClient::loginToken(const QString& username, const QString& token)
{
    m_refresh = false;
    QJsonObject post_content;
    post_content["u"] = username;
    post_content["t"] = token;

    sendRequest("login", post_content);
}

void RAClient::refresh()
{
    m_refresh = true;
    QJsonObject post_content;
    post_content["u"] = userinfo_model->username();
    post_content["t"] = userinfo_model->token();

    sendRequest("login", post_content);
}

void RAClient::loadGame(const QString& md5hash)
{
    gameinfo_model->md5hash(md5hash);
    QJsonObject post_content;
    post_content["m"] = md5hash;

    sendRequest("gameid", post_content);
}

void RAClient::getAchievements(const unsigned int& gameid)
{
    QJsonObject post_content;
    post_content["u"] = userinfo_model->username();
    post_content["t"] = userinfo_model->token();
    post_content["g"] = QString::number(gameid);

    sendRequest("patch", post_content);
}

void RAClient::getUnlocks()
{
    QJsonObject post_content;
    post_content["u"] = userinfo_model->username();
    post_content["t"] = userinfo_model->token();
    post_content["h"] = QString::number(userinfo_model->hardcore());
    post_content["g"] = QString::number(gameinfo_model->id());

    sendRequest("unlocks", post_content);
}

void RAClient::startSession()
{
    QJsonObject post_content;
    post_content["u"] = userinfo_model->username();
    post_content["t"] = userinfo_model->token();
    post_content["g"] = QString::number(gameinfo_model->id());
    post_content["h"] = userinfo_model->hardcore();
    post_content["m"] = gameinfo_model->md5hash();
    post_content["l"] = RCHEEVOS_VERSION_STRING;

    sendRequest("startsession", post_content);
}


void RAClient::ping(const QString& rp)
{
    QJsonObject post_content;
    post_content["u"] = userinfo_model->username();
    post_content["t"] = userinfo_model->token();
    post_content["g"] = QString::number(gameinfo_model->id());
    post_content["m"] = QString::fromUtf8(QUrl::toPercentEncoding(rp));
    post_content["h"] = userinfo_model->hardcore();
    post_content["x"] = gameinfo_model->md5hash();

    sendRequest("ping", post_content);
}

void RAClient::awardAchievement(const unsigned int& id, const QDateTime& achieved)
{
    achievedTimes[id] = achieved;
    QByteArray md5hash;
    md5hash.append(QString::number(id).toLocal8Bit());
    md5hash.append(userinfo_model->username().toLocal8Bit());
    md5hash.append(QString::number(userinfo_model->hardcore()).toLocal8Bit());
    int secondsPassed = std::abs(achieved.secsTo(QDateTime::currentDateTime()));
    md5hash.append(QString::number(id).toLocal8Bit());
    md5hash.append(QString::number(secondsPassed).toLocal8Bit());
    md5hash = QCryptographicHash::hash(md5hash, QCryptographicHash::Md5);

    QJsonObject post_content;
    post_content["u"] = userinfo_model->username();
    post_content["t"] = userinfo_model->token();
    post_content["a"] = QString::number(id);
    post_content["h"] = QString::number(userinfo_model->hardcore());
    post_content["v"] = QString(md5hash.toHex());

    sendRequest("awardachievement", post_content);
}

/*void RAClient::getLBPlacements()
{
    if(!gameinfo_model->leaderboards.empty() && index < gameinfo_model->leaderboards.size())
    {
        //qDebug() << "Getting Placements";
        QList<QPair<QString, QString>> post_content;
        post_content.append(qMakePair("i", QString::number(gameinfo_model->leaderboards.at(index).id)));
        post_content.append(qMakePair("u", userinfo_model->username));
        post_content.append(qMakePair("c", "1"));

        request("lbinfo", post_content);
    }
    else index = 0;
}*/

/*void RAClient::queueLeaderboardRequest(unsigned int id, QDateTime achieved, unsigned int score) {
    RequestData data = {LeaderboardRequest, id, true, achieved, score};
    queue.enqueue(data);
    if(!running)
        startQueue();
}*/

void RAClient::setPatched(const bool& p)
{
    userinfo_model->patched(p);
}

void RAClient::setSaveStates(const bool& s)
{
    userinfo_model->savestates(s);
}

void RAClient::setCheats(const bool& c)
{
    userinfo_model->cheats(c);
}

void RAClient::setHardcore(const bool& h)
{
    userinfo_model->hardcore(h);
}

void RAClient::setAutoHardcore(const bool& ac)
{
    userinfo_model->autohardcore(ac);
}

void RAClient::setInGameHooks(const bool& n)
{
    userinfo_model->ingamehooks(n);
}

bool RAClient::getAutoHardcore()
{
    return userinfo_model->autohardcore();
}

QString RAClient::getRichPresence()
{
    return gameinfo_model->rich_presence();
}

void RAClient::setTitleToHash(const QString& currentGame)
{
    gameinfo_model->title(gameinfo_model->md5hash());
    gameinfo_model->md5hash(currentGame);
}

void RAClient::setTitle(const QString& t, const QString& i, const QString& l)
{
    gameinfo_model->title(t);
    gameinfo_model->image_icon_url(QUrl(i));
    gameinfo_model->game_link(QUrl(l));
}

void RAClient::setHash(const QString& h)
{
    gameinfo_model->md5hash(h);
}

bool RAClient::getHardcore()
{
    return userinfo_model->hardcore();
}

void RAClient::clearAchievements()
{
    achievement_model->clearAchievements();
}

void RAClient::clearUser()
{
    userinfo_model->clearUser();
}

void RAClient::clearGame()
{
    gameinfo_model->clearGame();
}

QList<LeaderboardInfo> RAClient::getLeaderboards()
{
    return leaderboards;
}

void RAClient::setConsole(const QString& c, const QUrl& icon)
{
    gameinfo_model->console(c);
    gameinfo_model->console_icon(icon);
}

UserInfoModel* RAClient::getUserInfoModel()
{
    return userinfo_model;
}

AchievementModel* RAClient::getAchievementModel()
{
    return achievement_model;
}

void RAClient::setAchievementInfo(const unsigned int& id, const AchievementInfoType& infotype, const int& value)
{
    switch(infotype)
    {
        case Value:
            achievement_model->updateAchievementValue(id, value);
            break;
        case Percent:
            achievement_model->updateAchievementPercent(id, value);
            break;
        case Primed:
            achievement_model->primeAchievement(id, value);
            break;
        case Target:
            achievement_model->updateAchievementTarget(id, value);
            break;

    }
}

void RAClient::sendRequest(const QString& request_type, const QJsonObject& post_content)
{
    QNetworkRequest request{QUrl(baseUrl + "dorequest.php")};
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
    request.setRawHeader("User-Agent", userAgent.toUtf8());

    QUrlQuery query;
    query.addQueryItem("r", request_type);
    for (auto it = post_content.begin(); it != post_content.end(); ++it)
        query.addQueryItem(it.key(), it.value().toString());

    QByteArray postData = query.toString(QUrl::FullyEncoded).toUtf8();
    latestRequest = request_type;
    latestPost = post_content;
    networkManager->post(request, postData);
}

bool RAClient::sendQueuedRequest()
{
    if(queue.isEmpty() || running)
        return false;
    const auto& postRequest = queue.dequeue();
    running = true;
    sendRequest(postRequest.first, postRequest.second);
    return true;
}

/*void printJsonObject(const QJsonObject &jsonObject, int indent = 0) {
    QString indentString(indent, ' ');
    for (auto it = jsonObject.begin(); it != jsonObject.end(); ++it) {
        if (it.value().isObject()) {
            //qDebug() << indentString << it.key() << ": {";
            printJsonObject(it.value().toObject(), indent + 4);
            //qDebug() << indentString << "}";
        } else if (it.value().isArray()) {
            //qDebug() << indentString << it.key() << ": [";
            for (const auto &value : it.value().toArray()) {
                if (value.isObject()) {
                    printJsonObject(value.toObject(), indent + 4);
                } else {
                    //qDebug() << indentString << "  " << value.toString();
                }
            }
            //qDebug() << indentString << "]";
        } else {
            //qDebug() << indentString << it.key() << ":" << it.value().toString();
        }
    }
}

void printAchievements(QList<AchievementInfo> list)
{
    //qDebug() << list.size();
    for(const auto achievement : list)
    {
        //qDebug() << achievement.title;
        //qDebug() << achievement.flags;
    }
}*/

void RAClient::handleNetworkReply(QNetworkReply *reply)
{
    //qDebug() << "Latest Request: " << latestRequest;
    QJsonObject jsonObject = QJsonDocument::fromJson(reply->readAll()).object();
    //printJsonObject(jsonObject);

    if (reply->error() != QNetworkReply::NoError)
    {
        running = false;
        if(reply->errorString().contains("server replied"))
            emit requestError(false, latestRequest, reply->errorString());
        else
        {
            if(latestRequest == "awardachievement")
                queue.enqueue(qMakePair(latestRequest, latestPost));
            //qDebug() << "Network error:" << reply->errorString();
            emit requestError(true, latestRequest, reply->errorString());
        }
    }
    else if (jsonObject.contains("Error"))
    {
        //qDebug() << "Error:" << jsonObject["Error"].toString();
        if(jsonObject["Code"].toString() == "invalid_credentials")
            m_refresh = false;
        emit requestFailed(jsonObject);
    }
    else
    {
        if(!queue.isEmpty())
            queue.dequeue();
        else
            running = false;
        handleSuccessResponse(jsonObject);
    }
    reply->deleteLater();
}

void RAClient::handleSuccessResponse(const QJsonObject& jsonObject)
{
    if (latestRequest == "awardachievement")
        handleAwardAchievementResponse(jsonObject);
    else if (latestRequest == "ping")
        return;
    else if (latestRequest == "login")
        handleLoginResponse(jsonObject);
    else if (latestRequest == "gameid")
        handleGameIDResponse(jsonObject);
    else if (latestRequest == "patch")
        handlePatchResponse(jsonObject);
    else if (latestRequest == "unlocks")
        handleUnlocksResponse(jsonObject);
    else if (latestRequest == "startsession")
        handleStartSessionResponse(jsonObject);
    else
    {
        emit requestError(false, latestRequest, "Unexpected Response");
        //qDebug() << "Unexpected response:" << jsonObject;
    }
}

void RAClient::handleAwardAchievementResponse(const QJsonObject& jsonObject)
{
    //qDebug() << jsonObject;
    if(!achievement_model->getAchievements().isEmpty())
    {
        const auto& ach_list = achievement_model->getAchievements();
        for(int i = 0; i < ach_list.size(); i++)
        {
            auto& achievement = ach_list[i];
            if(achievement.id == jsonObject["AchievementID"].toInt())
            {
                achievement_model->setUnlockedState(i, true, achievedTimes[achievement.id]);
                achievedTimes.remove(achievement.id);
                gameinfo_model->updatePointCount(achievement.points);
                //qDebug() << "AWARDED" << achievement.id;
                gameinfo_model->updateCompletionCount();
                userinfo_model->hardcore_score(jsonObject["Score"].toInt());
                userinfo_model->softcore_score(jsonObject["SoftcoreScore"].toInt());
                if(progressionMap.contains(achievement.id))
                {
                    progressionMap[achievement.id] = true;
                    if(!gameinfo_model->beaten())
                        isGameBeaten();
                }
                break;
            }
        }
        isGameMastered();
    }
}

void RAClient::handleLoginResponse(const QJsonObject& jsonObject)
{
    userinfo_model->username(jsonObject["User"].toString());
    userinfo_model->token(jsonObject["Token"].toString());
    userinfo_model->softcore_score(jsonObject["SoftcoreScore"].toInt());
    userinfo_model->hardcore_score(jsonObject["Score"].toInt());
    userinfo_model->pfp((mediaUrl + "UserPic/" + userinfo_model->username() + ".png"));
    userinfo_model->link((baseUrl + "user/" + userinfo_model->username()));
    emit loginSuccess(m_refresh);
    m_refresh = false;
}

void RAClient::handleGameIDResponse(const QJsonObject& jsonObject)
{
    gameinfo_model->id(jsonObject["GameID"].toInt());
    emit gotGameID(gameinfo_model->id());
}

void RAClient::handlePatchResponse(const QJsonObject& jsonObject)
{
    QJsonObject patch_data = jsonObject["PatchData"].toObject();
    //qDebug() << jsonObject;
    gameinfo_model->title(patch_data["Title"].toString());
    gameinfo_model->image_icon(patch_data["ImageIcon"].toString());
    gameinfo_model->image_icon_url(QUrl(patch_data["ImageIconURL"].toString()));
    gameinfo_model->game_link(QUrl(baseUrl + "game/" + QString::number(gameinfo_model->id())));
    gameinfo_model->missable_count(0);
    gameinfo_model->point_total(0);
    gameinfo_model->mastered(false);
    gameinfo_model->completion_count(0);
    gameinfo_model->beaten(false);
    gameinfo_model->point_count(0);
    gameinfo_model->achievement_count(0);
    int missables = 0;
    int total = 0;
    warning = false;
    achievement_model->clearAchievements();
    progressionMap.clear();
    winMap.clear();

    QJsonArray achievements_data = patch_data["Achievements"].toArray();
    for (int i = 0; i < achievements_data.size(); ++i)
    {
        QJsonObject data = achievements_data[i].toObject();
        if (data["Flags"].toInt() == 3)
        {
            AchievementInfo info;
            info.badge_locked_url = QUrl(data["BadgeLockedURL"].toString());
            info.badge_name = data["BadgeName"].toString();
            info.badge_url = QUrl(data["BadgeURL"].toString());
            info.description = data["Description"].toString();
            info.flags = data["Flags"].toInt();
            info.mem_addr = data["MemAddr"].toString();
            info.points = data["Points"].toInt();
            //info.rarity = data["Rarity"].toInt();
            //info.rarity_hardcore = data["RarityHardcore"].toInt();
            info.title = data["Title"].toString();
            info.id = data["ID"].toInt();
            if(info.id != 101000001)
                info.unlocked = false;
            else
            {
                warning = true;
                info.unlocked = true;
            }
            info.type = data["Type"].toString();
            if(info.type == "progression")
                progressionMap[info.id] = info.unlocked;
            else if(info.type == "win_condition")
                winMap[info.id] = info.unlocked;
            //info.author = data["Author"].toString();
            info.time_unlocked_string = "";
            info.time_unlocked = QDateTime(QDate(1990, 11, 21), QTime(0, 0, 0));
            info.achievement_link = QUrl(baseUrl + "achievement/" + QString::number(info.id));
            info.primed = false;
            info.value = 0;
            info.target = 0;
            info.percent = 0;
            if(info.type == "missable")
                missables++;
            total += info.points;
            achievement_model->appendAchievement(info);
        }
    }
    gameinfo_model->missable_count(missables);
    gameinfo_model->point_total(total);
    gameinfo_model->achievement_count(achievement_model->rowCount() - warning);
    gameinfo_model->rich_presence(patch_data["RichPresencePatch"].toString().toUtf8());

    if (userinfo_model->hardcore())
    {
        QJsonArray leaderboards_data = patch_data["Leaderboards"].toArray();
        for (int i = 0; i < leaderboards_data.size(); ++i)
        {
            QJsonObject data = leaderboards_data[i].toObject();
            LeaderboardInfo info;
            info.description = data["Description"].toString();
            info.format = data["Format"].toString();
            info.id = data["id"].toInt();
            info.lower_is_better = data["LowerIsBetter"].toInt();
            info.mem_addr = data["Mem"].toString();
            info.leaderboard_link = QUrl(baseUrl + "leaderboard/" + QString::number(info.id));
        }

    }

    emit finishedGameSetup();
}

void RAClient::handleUnlocksResponse(const QJsonObject& jsonObject)
{
    emit finishedUnlockSetup();
}

void RAClient::handleStartSessionResponse(const QJsonObject& jsonObject)
{
    //qDebug() << jsonObject;
    QJsonArray unlock_data;
    if(userinfo_model->hardcore())
        unlock_data = jsonObject["HardcoreUnlocks"].toArray();
    else
        unlock_data = jsonObject["Unlocks"].toArray();
    int complete = unlock_data.count();
    for (int i = 0; i < unlock_data.size(); i++)
    {
        QJsonObject unlock = unlock_data[i].toObject();
        if(unlock["ID"].toInt() != 101000001)
        {
            const auto& ach_list = achievement_model->getAchievements();
            for(int i = 0; i < ach_list.size(); i++)
            {
                auto& achievement = ach_list[i];
                if(achievement.type == "progression")
                    progressionMap[achievement.id] = achievement.unlocked;
                else if(achievement.type == "win_condition")
                    winMap[achievement.id] = achievement.unlocked;
                if(unlock["ID"].toInt() == achievement.id)
                {
                    achievement_model->setUnlockedState(i, true, QDateTime::fromSecsSinceEpoch(unlock["When"].toInt()));
                    gameinfo_model->updatePointCount(achievement.points);
                }
            }
        }
        else complete--;
    }
    gameinfo_model->completion_count(complete);
    if(!isGameMastered())
        isGameBeaten();
    emit sessionStarted();
}

bool RAClient::isGameBeaten()
{
    //qDebug() << progressionMap;
    //qDebug() << winMap;
    if(progressionMap.empty() || achievement_model->rowCount() < 1)
        return false;
    for(auto it = progressionMap.constBegin(); it != progressionMap.constEnd(); it++) {
        if(!it.value()) {
            gameinfo_model->beaten(false);
            return false;
        }
    }
    for(auto it = winMap.constBegin(); it != winMap.constEnd(); it++) {
        if(it.value()) {
            gameinfo_model->beaten(true);
            return true;
        }
    }
    gameinfo_model->beaten(false);
    return false;
}

bool RAClient::isGameMastered()
{
    if(achievement_model->rowCount() < 1)
        return false;
    if((gameinfo_model->completion_count() + warning) == achievement_model->rowCount())
    {
        gameinfo_model->mastered(true);
        return true;
    }
    gameinfo_model->mastered(false);
    return false;
}

RAClient::~RAClient()
{
}
