#ifndef RA2SNES_H
#define RA2SNES_H

#include "usb2snes.h"
#include "raclient.h"
#include "memoryreader.h"
#include "version.h"

class ra2snes : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString console READ console WRITE setConsole NOTIFY consoleChanged)
    Q_PROPERTY(QString appDirPath READ appDirPath WRITE setAppDirPath NOTIFY appDirPathChanged)
    Q_PROPERTY(QString theme READ theme WRITE setTheme NOTIFY themeChanged)
    Q_PROPERTY(QString version READ version CONSTANT)
    Q_PROPERTY(QString latestVersion READ latestVersion NOTIFY newUpdate)

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

    bool isRemembered();
    QString xorEncryptDecrypt(const QString &token, const QString &key);
    QString console() const;
    void setConsole(const QString &console);
    QString appDirPath() const;
    void setAppDirPath(const QString &appDirPath);
    QString theme() const;
    QString version() const;
    QString latestVersion() const;

public slots:
    void signIn(const QString &username, const QString &password, bool remember);
    void signOut();
    void saveUISettings(int w, int h, bool c);
    void changeMode();
    void autoChange(bool ac);
    void refreshRAData();
    void setTheme(const QString &theme);
    void beginUpdate();

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
    void newUpdate();

private:
    explicit ra2snes(QObject *parent = nullptr);
    ~ra2snes();
    ra2snes(const ra2snes&) = delete;
    ra2snes& operator=(const ra2snes&) = delete;

    Usb2Snes *usb2snes;
    RAClient *raclient;
    MemoryReader *reader;
    QString m_currentGame;
    const QString m_version = RA2SNES_VERSION_STRING;
    bool loggedin;
    bool gameLoaded;
    bool loadingGame;
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
    QString m_latestVersion;
    QString downloadUrl;

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
    void checkForUpdate();
};

#endif // RA2SNES_H
