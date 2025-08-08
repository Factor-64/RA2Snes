#include "ra2snes.h"
#include <QSettings>
#include <QApplication>
#include <QFile>
#include <QDir>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValue>
#include <QProcess>
//#include <QDebug>

ra2snes::ra2snes(QObject *parent)
    : QObject(parent)
{
    usb2snes = new Usb2Snes(false);
    reader = new MemoryReader(this);
    raclient = RAClient::instance();
    reset = false;
    m_console = "SNES";
    m_theme = "Dark";
    m_latestVersion = "";
    downloadUrl = "";
    m_appDirPath = "";
    richText = "";
    initVars();
    crashTimer = new QTimer(this);
    richTimer = new QTimer(this);
    waitTimer = new QTimer(this);
    frameTimer = new QElapsedTimer();
    crashTimer->setSingleShot(true);
    richTimer->setSingleShot(true);

    connect(crashTimer, &QTimer::timeout, this, [=]() {
        emit displayMessage("SD2Snes Firmware is unresponsive. Please power cycle the console.", true);
        if(raclient->sendQueuedRequest())
            crashTimer->start(1000);
        else
            crashTimer->start(5000);
    });

    connect(richTimer, &QTimer::timeout, this, [=]() {
        if(!richText.isEmpty())
            raclient->ping(richText);
        richTimer->start(120000);
    });

    connect(waitTimer, &QTimer::timeout, this, [=]() {
        //qDebug() << "ELAPSED" << frameTimer->elapsed();
        onUsb2SnesStateChanged();
    });

    connect(usb2snes, &Usb2Snes::connected, this, [=]() {
        usb2snes->setAppName("RA2Snes");
        //qDebug() << "Connected to usb2snes server, trying to find a suitable device";
        raclient->clearAchievements();
        usb2snes->deviceList();
        emit displayMessage("QUsb2Snes Connected", false);
    });

    connect(usb2snes, &Usb2Snes::disconnected, this, [=]() {
        if(crashTimer->isActive())
            crashTimer->stop();
        if(richTimer->isActive())
            richTimer->stop();
        //qDebug() << "Disconnected, trying to reconnect in 1 sec";
        emit displayMessage("QUsb2Snes Not Connected", true);
        raclient->clearAchievements();
        emit clearedAchievements();
        raclient->clearGame();
        QTimer::singleShot(1000, this, [=] {
            raclient->sendQueuedRequest();
            usb2snes->connect();
        });
    });

    connect(usb2snes, &Usb2Snes::deviceListDone, this, [=] (QStringList devices) {
        if (!devices.empty())
        {
            doThisTaskNext = None;
            reset = true;
            usb2snes->attach(devices.at(0));
            usb2snes->infos(true);
            emit displayMessage("Console Connected", false);
        }
        else
        {
            if(crashTimer->isActive())
                crashTimer->stop();
            m_currentGame = "";
            raclient->clearAchievements();
            emit clearedAchievements();
            raclient->clearGame();
            emit displayMessage("Console Not Connected", true);
            QTimer::singleShot(1000, this, [=] {
                raclient->sendQueuedRequest();
                if (usb2snes->state() == Usb2Snes::Connected)
                    usb2snes->deviceList();
            });
        }
    });

    connect(usb2snes, &Usb2Snes::stateChanged, this, &ra2snes::onUsb2SnesStateChanged);
    connect(usb2snes, &Usb2Snes::gotServerVersion, this, [=] {usb2snes->infos(); });
    connect(usb2snes, &Usb2Snes::infoDone, this, &ra2snes::onUsb2SnesInfoDone);
    connect(usb2snes, &Usb2Snes::getFileDataReceived, this, &ra2snes::onUsb2SnesGetFileDataReceived);
    connect(usb2snes, &Usb2Snes::getConfigDataReceived, this, &ra2snes::onUsb2SnesGetConfigDataReceived);
    connect(usb2snes, &Usb2Snes::getAddressesDataReceived, this, &ra2snes::onUsb2SnesGetAddressesDataReceived);
    connect(usb2snes, &Usb2Snes::getAddressDataReceived, this, &ra2snes::onUsb2SnesGetAddressDataReceived);
    connect(usb2snes, &Usb2Snes::getRomTypeDataReceived, this, [=] { doThisTaskNext = GetRamSize; });
    connect(usb2snes, &Usb2Snes::retryRomType, this, [=] { doThisTaskNext = GetRomType; });

    QTimer::singleShot(0, this, [=] { usb2snes->connect(); });

    connect(raclient, &RAClient::loginSuccess, this, &ra2snes::onLoginSuccess);
    connect(raclient, &RAClient::requestFailed, this, &ra2snes::onRequestFailed);
    connect(raclient, &RAClient::requestError, this, &ra2snes::onRequestError);
    connect(raclient, &RAClient::gotGameID, this, [=] (const int& id){
        m_gameLoaded = true;
        m_loadingGame = false;
        emit displayMessage("Game Loaded", false);
        raclient->getAchievements(id);
    });

    connect(raclient, &RAClient::finishedGameSetup, this, [=] {
        raclient->getUnlocks();
    });

    connect(raclient, &RAClient::finishedUnlockSetup, this, [=] {
        raclient->startSession();
    });
    connect(raclient, &RAClient::sessionStarted, this, [=] {
        emit achievementModelReady();
        emit enableModeSwitching();
        reader->initTriggers(raclient->getAchievementModel()->getAchievements(), raclient->getLeaderboards(), raclient->getRichPresence(), usb2snes->getRamSizeData());
    });

    connect(reader, &MemoryReader::finishedMemorySetup, this, [=] {
        doThisTaskNext = None;
        uniqueMemoryAddresses = reader->getUniqueMemoryAddresses();
        //qDebug() << "Unique Addresses:" << uniqueMemoryAddresses;
        if(uniqueMemoryAddresses.empty())
            doThisTaskNext = NoChecksNeeded;
        else
        {
            if(raclient->getHardcore())
                doThisTaskNext = CheckPatched;
            else
                doThisTaskNext = GetConsoleAddresses;
        }
        if(!richTimer->isActive())
            richTimer->start(30000);
        frameTimer->restart();
        usb2snes->infos();
    });

    connect(reader, &MemoryReader::achievementUnlocked, this, [=](const unsigned int& id, const QDateTime& time) {
        //qDebug() << id << time;
        raclient->awardAchievement(id, time);
    });

    connect(reader, &MemoryReader::updateAchievementInfo, this, [=](const unsigned int& id, const AchievementInfoType& infotype, const int& value) {
        raclient->setAchievementInfo(id, infotype, value);
    });

    connect(reader, &MemoryReader::modifiedAddresses, this, [=] {
        updateAddresses = true;
    });

    connect(reader, &MemoryReader::updateRichPresence, this, [=](const QString& status) {
        richText = status;
        emit updatedRichText();
    });

    //connect(reader, &MemoryReader::leaderboardCompleted, this, [=](unsigned int id, unsigned int score) {
    //    raclient->queueLeaderboardRequest(id, score);
    //    if(!raclient->isQueueRunning())
    //        QThreadPool::globalInstance()->start([=] { raclient->runQueue(); });
    //});
}

void ra2snes::signIn(const QString &username, const QString &password, const bool& remember)
{
    remember_me = remember;
    raclient->loginPassword(username, password);
}

void ra2snes::onUsb2SnesInfoDone(Usb2Snes::DeviceInfo infos)
{
    if (!infos.flags.contains("NO_FILE_CMD"))
    {
        m_currentGame = infos.romPlaying.remove(QChar('\u0000'));
        m_currentGame.replace("?", " ");
        if (m_currentGame.contains("m3nu.bin") || m_currentGame.contains("menu.bin") || reset)
        {
            if(reset)
            {
                emit displayMessage("", false);
                usb2snes->clearBinaryData();
            }
            doThisTaskNext = GetConsoleConfig;
            reset = false;
            m_gameLoaded = false;
            raclient->setPatched(false);
            raclient->clearAchievements();
            emit clearedAchievements();
            raclient->clearGame();
            setCurrentConsole();
            richText = "";
            emit updatedRichText();
            if(richTimer->isActive())
                richTimer->stop();
        }
        else if (!m_gameLoaded && loggedin && !m_loadingGame)
        {
            doThisTaskNext = GetRomType;
            emit disableModeSwitching();
            if(raclient->getAutoHardcore() && !raclient->getHardcore())
                changeMode();
            m_loadingGame = true;
            setCurrentConsole();
            emit displayMessage("Loading... Do Not Turn Off Console!", false);
        }
        else
            if(crashTimer->isActive())
                crashTimer->stop();
    }
}

void ra2snes::onUsb2SnesGetFileDataReceived()
{
    QByteArray romData = usb2snes->getBinaryData();
    if (romData.size() & 512)
        romData = romData.mid(512);
    QByteArray md5Hash = QCryptographicHash::hash(romData, QCryptographicHash::Md5);
    raclient->loadGame(md5Hash.toHex());
}

void ra2snes::onUsb2SnesGetConfigDataReceived()
{
    //qDebug() << "Checking config";
    QString config = QString::fromUtf8(usb2snes->getBinaryData());
    if(config.contains("EnableCheats"))
    {
        bool c = !config.contains("EnableCheats: false");
        bool s = !config.contains("EnableIngameSavestate: 0");
        bool n = !config.contains("\nEnableIngameHook: false");

        if(isGB)
        {
            s = !config.contains("SGBEnableState: false");
            n = !config.contains("SGBEnableIngameHook: false");
        }
        raclient->setCheats(c);
        raclient->setSaveStates(s);
        raclient->setInGameHooks(n);
        if((c || s || n) && raclient->getHardcore())
            changeMode();
        else if(raclient->getAutoHardcore() && !raclient->getHardcore())
            changeMode();
    }
    else
        reset = true;
}

void ra2snes::onUsb2SnesGetAddressesDataReceived()
{
    vgetTime = frameTimer->restart();
    unsigned int framesPassed = std::round(std::abs((vgetTime + programTime) * 0.0600988138974405));
    if(framesPassed < 1)
        framesPassed = 1;
    //qDebug() << "Frames: " << framesPassed;
    reader->processFrames(usb2snes->getBinaryData(), framesPassed);
    //qDebug() << usb2snes->getBinaryData();
}

void ra2snes::onUsb2SnesGetAddressDataReceived()
{
    QByteArray data = usb2snes->getBinaryData();
    bool patched = false;
    //qDebug() << "Checking for patched rom";
    //qDebug() << data;
    //if(data[0] != '\x00')
    //    qDebug() << "RESET";
    if (usb2snes->firmwareVersion() > QVersionNumber(7))
    {
        if(data[1] != '\x00' && data[3] != '\x00')
            patched = true;
    }
    else if (data[0] != (char)0x60)
        patched = true;
    if (patched)
    {
        //qDebug() << "ROM PATCHED!";
        raclient->setPatched(true);
        changeMode();
    }
    else
        raclient->setPatched(false);
    //qDebug() << "Finished Patch Check";
}

void ra2snes::onLoginSuccess(bool r)
{
    loggedin = true;
    createSettingsFile();
    reset = true;
    //qDebug() << "logged" << r;
    if(!r)
    {
        emit loginSuccess();
        QTimer::singleShot(1000, this, [=] {
            if(downloadUrl != "")
                emit newUpdate();
        });
    }
    onUsb2SnesStateChanged();
}

void ra2snes::onRequestFailed(const QJsonObject& error)
{
    QString errorMessage = error["Error"].toString();
    //qDebug() << "Code:" << error["Code"].toString() << "Error:" << errorMessage;
    if(error["Code"].toString() == "invalid_credentials")
    {
        if(errorMessage.contains("token"))
        {
            remember_me = false;
            createSettingsFile();
        }
        emit loginFailed(errorMessage.remove(" Please try again."));
    }
}

void ra2snes::onRequestError(const bool& net, const QString& request, const QString& error)
{
    if(net)
    {
        if(request == "login" && raclient->getUserInfoModel()->hardcore_score() < 0)
        {
            raclient->getUserInfoModel()->hardcore_score(0);
            emit signedOut();
            emit loginFailed("Network Error!");
        }
        emit displayMessage("Network Error: " + error, true);
    }
    else
    {
        if(crashTimer->isActive())
            crashTimer->stop();
        if(richTimer->isActive())
            richTimer->stop();
        doThisTaskNext = NoChecksNeeded;
        emit displayMessage("Game Hash does not exist!", true);
        raclient->setTitleToHash(m_currentGame);
        onUsb2SnesStateChanged();
    }
    //qDebug() << "request error";
}

void ra2snes::onUsb2SnesStateChanged()
{
    //qDebug() << "Task Finished: " << doThisTaskNext;
    //qDebug() << "State: " << usb2snes->state();
    //qDebug() << "Reset? " << reset;
    if(crashTimer->isActive())
        crashTimer->stop();
    crashTimer->start(10000);
    if(usb2snes->state() == Usb2Snes::Ready)
    {
        if(reset)
            doThisTaskNext = Reset;
        switch(doThisTaskNext)
        {
            case CheckPatched:
                //qDebug() << "check patch";
                doThisTaskNext = GetConsoleAddresses;
                if(raclient->getHardcore())
                {
                    usb2snes->isPatchedROM();
                    break;
                }
                else if(!m_gameLoaded)
                    break;
            case GetConsoleAddresses:
                //qDebug() << "get addresses";
                doThisTaskNext = GetConsoleInfo;
                if(updateAddresses)
                {
                    uniqueMemoryAddresses = reader->getUniqueMemoryAddresses();
                    updateAddresses = false;
                }
                programTime = frameTimer->elapsed();
                //qDebug() << "PT" << programTime << "VT" << vgetTime;
                if(programTime + vgetTime > 15)
                {
                    frameTimer->restart();
                    usb2snes->getAddresses(uniqueMemoryAddresses);
                }
                else
                {
                    doThisTaskNext = GetConsoleAddresses;
                    int time = 16 - (programTime + vgetTime);
                    if(time > 0)
                        waitTimer->start(time);
                    else
                        onUsb2SnesStateChanged();
                }
                break;
            case GetConsoleInfo:
                //qDebug() << "infos";
                if(m_loadingGame || m_gameLoaded)
                    doThisTaskNext = CheckPatched;
                else
                    doThisTaskNext = GetConsoleConfig;
                usb2snes->infos();
                break;
            case Reset:
                //qDebug() << "reset";
                doThisTaskNext = None;
                usb2snes->infos();
                break;
            case NoChecksNeeded:
                //qDebug() << "nothing";
                doThisTaskNext = NoChecksNeeded;
                usb2snes->infos();
                break;
            case GetConsoleConfig:
                //qDebug() << "console config";
                if(m_loadingGame)
                    doThisTaskNext = GetCurrentGameFile;
                else
                    doThisTaskNext = GetConsoleInfo;
                usb2snes->getConfig();
                break;
            case GetCurrentGameFile:
                //qDebug() << "get game";
                doThisTaskNext = None;
                usb2snes->getFile(m_currentGame);
                break;
            case GetRomType:
                //qDebug() << "get rom type";
                doThisTaskNext = None;
                usb2snes->getRomType();
                break;
            case GetRamSize:
                //qDebug() << "get ram size";
                doThisTaskNext = GetConsoleConfig;
                usb2snes->getRamSize();
                break;
            default:
                break;
        }
    }
    else if(usb2snes->state() == Usb2Snes::None)
    {
        doThisTaskNext = None;
        m_gameLoaded = false;
        m_currentGame = "";
        setCurrentConsole();
    }
    else if(usb2snes->state() == Usb2Snes::ReceivingFile)
        emit displayMessage("Loading... Do Not Turn Off Console!", false);
    raclient->sendQueuedRequest();
}

void ra2snes::setCurrentConsole()
{
    int extensionIndex = m_currentGame.lastIndexOf('.');
    if(extensionIndex != -1)
    {
        QString icon = "https://static.retroachievements.org/assets/images/system/";
        QString extension = m_currentGame.mid(extensionIndex + 1);
        if(extension == "sfc" || extension == "smc" || extension == "swc" || extension == "bs" || extension == "fig")
        {
            setConsole("SNES");
            isGB = false;
        }
        else if(extension == "gb")
        {
            setConsole("SNES");
            isGB = true;
        }
        if(m_console == "SNES")
        {
            raclient->setTitle("SD2SNES Menu", "https://avatars.githubusercontent.com/u/238664?v=4", "https://sd2snes.de/blog/");
            raclient->setHash("https://github.com/mrehkopf/sd2snes");
            if(isGB)
            {
                icon += "gb.png";
                raclient->setConsole("Super Game Boy", QUrl(icon));
            }
            else
            {
                icon += "snes.png";
                raclient->setConsole("SNES/Super Famicom", QUrl(icon));
            }
        }
    }
    else
    {
        raclient->setTitle("", "", "");
        raclient->setConsole("", QUrl(""));
    }
}

QString ra2snes::xorEncryptDecrypt(const QString &token, const QString &key) {
    QString result = token;
    int keyLength = key.length();

    for (int i = 0; i < token.length(); ++i) {
        result[i] = QChar(token[i].unicode() ^ key[i % keyLength].unicode());
    }

    return result;
}

void ra2snes::saveUISettings(const int& w, const int& h, const bool& c)
{
    UserInfoModel* user = raclient->getUserInfoModel();
    user->width(w);
    user->height(h);
    user->compact(c);
    createSettingsFile();
}

void ra2snes::createSettingsFile()
{
    if(m_appDirPath != "")
    {
        QString settingsFilePath = m_appDirPath + QDir::separator() + "settings.ini";

        //qDebug() << settingsFilePath;
        QSettings settings(settingsFilePath, QSettings::IniFormat);

        UserInfoModel* user = raclient->getUserInfoModel();

        settings.setValue("Hardcore", user->hardcore());
        settings.setValue("Console", m_console);
        settings.setValue("Width", user->width());
        settings.setValue("Height", user->height());
        settings.setValue("Auto", user->autohardcore());
        settings.setValue("Compact", user->compact());
        settings.setValue("Theme", m_theme);
        settings.setValue("IgnoreUpdates", m_ignore);

        if(remember_me)
        {
            QString time = QString::number(QDateTime::currentSecsSinceEpoch());
            settings.setValue("Username", user->username());
            settings.setValue("Token", xorEncryptDecrypt(user->token(), time));
            settings.setValue("Time", time);
        }
        else
        {
            settings.setValue("Username", "");
            settings.setValue("Token", "");
            settings.setValue("Time", "");
        }

        settings.sync();
    }
}

void ra2snes::loadSettings() {
    QString appDir = QCoreApplication::applicationDirPath();

    QString settingsFilePath = appDir + QDir::separator() + "settings.ini";

    //qDebug() << appDir;

    if (QFile::exists(settingsFilePath)) {
        QSettings settings(settingsFilePath, QSettings::IniFormat);

        bool hardcore = settings.value("Hardcore").toBool();
        QString console_v = settings.value("Console").toString();
        QString username = settings.value("Username").toString();
        QString token = settings.value("Token").toString();
        QString time = settings.value("Time").toString();
        int width = settings.value("Width").toInt();
        int height = settings.value("Height").toInt();
        bool autoh = settings.value("Auto").toBool();
        bool comp = settings.value("Compact").toBool();
        bool igno = settings.value("IgnoreUpdates").toBool();
        QString theme = settings.value("Theme").toString();

        UserInfoModel* user = raclient->getUserInfoModel();
        user->hardcore(hardcore);
        user->autohardcore(autoh);
        user->width(width);
        user->height(height);
        user->compact(comp);
        setConsole(console_v);
        setTheme(theme);

        m_ignore = igno;

        if(username != "" && token != "" && time != "")
        {
            remember_me = true;
            user->hardcore_score(-1);
            raclient->loginToken(username, xorEncryptDecrypt(token, time));
        }
        else
            QTimer::singleShot(0, this, [=] { emit signedOut(); });
    }
    else
    {
        createSettingsFile();
        QTimer::singleShot(0, this, [=] { emit signedOut(); });
    }
    setCurrentConsole();
}

void ra2snes::signOut()
{
    initVars();
    reset = true;
    loadSettings();
    onUsb2SnesStateChanged();
}

void ra2snes::initVars()
{
    vgetTime = 16;
    programTime = 0;
    m_currentGame = "";
    loggedin = false;
    m_gameLoaded = false;
    m_loadingGame = false;
    isGB = false;
    doThisTaskNext = None;
    remember_me = false;
    m_ignore = false;
    updateAddresses = false;
    raclient->clearAchievements();
    raclient->clearUser();
    raclient->clearGame();
    raclient->setHardcore(true);
    raclient->setAutoHardcore(false);
    saveUISettings(600, 600, false);
}

void ra2snes::changeMode()
{
    emit disableModeSwitching();
    //qDebug() << "Changing Mode";
    UserInfoModel* user = raclient->getUserInfoModel();
    QString reason = "Hardcore Disabled: ";
    bool needsChange = false;
    //qDebug() << alreadySoftcore;
    if(user->cheats()) {
        reason += QString("Cheats Enabled");
        needsChange = true;
    }
    if(user->savestates()) {
        if(isGB)
            reason += (QString(needsChange ? ", " : "") + "Super Game Boy SaveStates Enabled");
        else
            reason += (QString(needsChange ? ", " : "") + "SaveStates Enabled");
        needsChange = true;
    }
    if(user->patched()) {
        reason += (QString(needsChange ? ", " : "") + "ROM Patched");
        needsChange = true;
    }
    if(user->ingamehooks())
    {
        reason += (QString(needsChange ? ", " : "") + "InGameHooks Enabled");
        needsChange = true;
    }
    if(!needsChange)
    {
        if(user->autohardcore())
        {
            user->hardcore(true);
            emit displayMessage("Hardcore Enabled", false);
        }
        else
            user->hardcore(!user->hardcore());
    }
    else
    {
        user->hardcore(false);
        emit displayMessage(reason, true);
    }
    if(m_gameLoaded)
    {
        if(user->patched())
            doThisTaskNext = NoChecksNeeded;
        else
            reset = true;
        onUsb2SnesStateChanged();
    }
    else if(!m_gameLoaded)
    {
        //qDebug() << "Enabling Mode Switching";
        emit enableModeSwitching();
    }
}

void ra2snes::autoChange(const bool& ac)
{
    raclient->setAutoHardcore(ac);
    if(raclient->getAutoHardcore() && !raclient->getHardcore())
        changeMode();
}

QString ra2snes::console() const
{
    return m_console;
}

void ra2snes::setConsole(const QString &console)
{
    if (m_console != console) {
        m_console = console;
        emit consoleChanged();
    }
}

void ra2snes::setAppDirPath(const QString &appDirPath)
{
    m_appDirPath = appDirPath;
    loadSettings();
    if(!m_ignore)
        checkForUpdate();
}

QString ra2snes::appDirPath() const
{
    return m_appDirPath;
}

QString ra2snes::richPresence() const
{
    return richText;
}

void ra2snes::setTheme(const QString &theme)
{
    if (m_theme != theme) {
        m_theme = theme;
        emit themeChanged();
    }
}

QString ra2snes::theme() const
{
    return m_theme;
}

QString ra2snes::version() const
{
    return m_version;
}

QString ra2snes::latestVersion() const
{
    return m_latestVersion;
}

bool ra2snes::ignore() const
{
    return m_ignore;
}

void ra2snes::refreshRAData()
{
    reset = true;
    loggedin = false;
    raclient->refresh();
}

void ra2snes::checkForUpdate() {
    QNetworkAccessManager *tempNetworkManager = new QNetworkAccessManager(this);

    connect(tempNetworkManager, &QNetworkAccessManager::finished, this, [this, tempNetworkManager](QNetworkReply *reply) {
        if (reply->error() == QNetworkReply::NoError) {
            QJsonDocument jsonDoc = QJsonDocument::fromJson(reply->readAll());
            QJsonObject jsonObj = jsonDoc.object();
            m_latestVersion = jsonObj["tag_name"].toString();
            m_latestVersion.replace("v", "");
            //qDebug() << m_latestVersion;
            //qDebug() << m_version;
            if (QVersionNumber::fromString(m_latestVersion) > QVersionNumber::fromString(m_version)) {
                QJsonArray assets = jsonObj["assets"].toArray();

                for (int i = 0; i < assets.size(); i++) {
                    const QJsonObject assetObj = assets.at(i).toObject();
                    const QString assetName = assetObj["name"].toString();
#ifdef Q_OS_WIN
                    if (assetName.endsWith("windows-x64.zip")) {
                        downloadUrl = assetObj["browser_download_url"].toString();
                        break;
                    }
#elif defined(Q_OS_LINUX)
                    if (assetName.endsWith("linux-x64.zip")) {
                        downloadUrl = assetObj["browser_download_url"].toString();
                        break;
                    }
#elif defined(Q_OS_MACOS)
                    if (assetName.endsWith("macos-x64.zip")) {
                        downloadUrl = assetObj["browser_download_url"].toString();
                        break;
                    }
#endif
                }
            }
        } else {
            //qDebug() << "Network error:" << reply->errorString();
        }

        reply->deleteLater();
        tempNetworkManager->deleteLater();
    });

    QUrl apiUrl(QString("https://api.github.com/repos/%1/releases/latest").arg(RA2SNES_REPO_URL));
    QNetworkRequest request(apiUrl);
    tempNetworkManager->get(request);
}

void ra2snes::beginUpdate() {
#ifdef Q_OS_WIN
    QString program = m_appDirPath + QDir::separator() + "updater.exe";
#elif defined(Q_OS_LINUX)
    QString program = m_appDirPath + QDir::separator() + "updater";
#elif defined(Q_OS_MACOS)
    QString program = m_appDirPath + QDir::separator() + "updater.app";
#endif

    QStringList arguments;
    arguments << downloadUrl;
    if (QProcess::startDetached(program, arguments)) {
        //qDebug() << "Updater process started successfully.";
        QCoreApplication::quit();
    }
    /*else {
        qDebug() << "Failed to start updater process.";
    }*/
}

void ra2snes::ignoreUpdates(bool i)
{
    m_ignore = i;
    emit ignoreChanged();
}

ra2snes::~ra2snes()
{}
