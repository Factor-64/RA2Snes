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

public slots:
    void signIn(const QString &username, const QString &password, bool remember);
    void signOut();
    void saveWindowSize(int w, int h);
    void changeMode();
    void autoChange(bool ac);

signals:
    void loginSuccess();
    void loginFailed(QString error);
    void changeModeFailed(QString reason);
    void achievementModelReady();
    void signedOut();
    void switchingMode();
    void clearedAchievements();
    void displayMessage(QString error, bool iserror);
    void autoModeChanged();
    void consoleChanged();

private:
    explicit ra2snes(QObject *parent = nullptr);  // Private constructor
    ~ra2snes();  // Private destructor
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
    void runAddressesLogic();
};

#endif // RA2SNES_H
