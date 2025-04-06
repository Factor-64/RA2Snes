#ifndef RA2SNES_H
#define RA2SNES_H

#include "usb2snes.h"
#include "raclient.h"
#include "memoryreader.h"
#include "achievementmodel.h"
#include "gameinfomodel.h"
#include "userinfomodel.h"

class ra2snes : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString console READ console WRITE setConsole NOTIFY consoleChanged)
    Q_PROPERTY(QString appDirPath READ appDirPath WRITE setAppDirPath NOTIFY appDirPathChanged)
    Q_PROPERTY(QString theme READ theme WRITE setTheme NOTIFY themeChanged)

public:
    enum Task {
        None,
        GetConsoleInfo,
        GetConsoleAddresses,
        GetConsoleConfig,
        GetCurrentGameFile,
        CheckPatched,
        ClearLeftOverData,
        Reset,
        NoChecksNeeded,
        GetRamSize,
        GetRomType,
        GetFirmware
    };

    static ra2snes* instance() {
        static ra2snes instance;
        return &instance;
    }

    AchievementModel* achievementModel();
    GameInfoModel* gameInfoModel();
    UserInfoModel* userInfoModel();
    bool isRemembered();
    QString xorEncryptDecrypt(const QString &token, const QString &key);
    QString console() const;
    void setConsole(const QString &console);
    QString appDirPath() const;
    void setAppDirPath(const QString &appDirPath);
    QString theme() const;

public slots:
    void signIn(const QString &username, const QString &password, bool remember);
    void signOut();
    void saveWindowSize(int w, int h);
    void changeMode();
    void autoChange(bool ac);
    void refreshRAData();
    void setTheme(const QString &theme);

signals:
    void loginSuccess();
    void loginFailed(QString error);
    void changeModeFailed(QString reason);
    void achievementModelReady();
    void signedOut();
    void clearedAchievements();
    void displayMessage(QString error, bool iserror);
    void consoleChanged();
    void appDirPathChanged();
    void themeChanged();
    void disableModeSwitching();
    void enableModeSwitching();

private:
    explicit ra2snes(QObject *parent = nullptr);
    ~ra2snes();
    ra2snes(const ra2snes&) = delete;
    ra2snes& operator=(const ra2snes&) = delete;

    Usb2Snes *usb2snes;
    RAClient *raclient;
    MemoryReader *reader;
    QString m_currentGame;
    bool loggedin;
    bool gameLoaded;
    bool remember_me;
    bool isGB;
    bool reset;
    QAtomicInt updateAddresses;
    QString m_console;
    unsigned int framesPassed;
    QDateTime millisecPassed;
    Task doThisTaskNext;
    QList<QPair<int, int>> uniqueMemoryAddresses;
    QString m_appDirPath;
    QString m_theme;

    void createSettingsFile();
    void loadSettings();
    void onLoginSuccess();
    void onRequestFailed(QJsonObject error);
    void onRequestError(bool net);
    void onUsb2SnesStateChanged();
    void onUsb2SnesGetAddressDataReceived();
    void onUsb2SnesGetAddressesDataReceived();
    void onUsb2SnesGetConfigDataReceived();
    void onUsb2SnesGetFileDataReceived();
    void onUsb2SnesInfoDone(Usb2Snes::DeviceInfo infos);
    void setCurrentConsole();
};

#endif // RA2SNES_H
