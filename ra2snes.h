#ifndef RA2SNES_H
#define RA2SNES_H

#include <QTimer>
#include <QJsonObject>
#include <QElapsedTimer>
#include "usb2snes.h"
#include "raclient.h"
#include "memoryreader.h"
#include "version.h"

class ra2snes : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString console READ console WRITE setConsole NOTIFY consoleChanged)
    Q_PROPERTY(QString appDirPath READ appDirPath CONSTANT)
    Q_PROPERTY(QString version READ version CONSTANT)
    Q_PROPERTY(QString latestVersion READ latestVersion NOTIFY newUpdate)
    Q_PROPERTY(bool ignore READ ignore WRITE ignoreUpdates NOTIFY ignoreChanged)
    Q_PROPERTY(QString richPresence READ richPresence NOTIFY updatedRichText)

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
        GetFirmware,
        SetupNMIData,
        GetNMIData
    };
    Q_ENUM(Task)

    static ra2snes* instance() {
        static ra2snes instance;
        return &instance;
    }

    QString xorEncryptDecrypt(const QString &token, const QString &key);
    QString console() const;
    void setConsole(const QString &console);
    QString appDirPath() const;
    void setAppDirPath(const QString &appDirPath);
    QString theme() const;
    QString version() const;
    QString latestVersion() const;
    QString richPresence() const;
    bool ignore() const;

public slots:
    void signIn(const QString &username, const QString &password, const bool& remember);
    void signOut();
    void saveUISettings(const int& w, const int& h, const bool& c, const bool& b, const bool& i, const bool& ip, const QString t);
    void changeMode();
    void autoChange(const bool& ac);
    void refreshRAData();
    void beginUpdate();
    void ignoreUpdates(bool i);

signals:
    void loginSuccess();
    void loginFailed(const QString& error);
    void changeModeFailed(const QString& reason);
    void achievementModelReady();
    void signedOut();
    void clearedAchievements();
    void displayMessage(const QString& error, const bool& iserror);
    void consoleChanged();
    void themeChanged();
    void disableModeSwitching();
    void enableModeSwitching();
    void newUpdate();
    void ignoreChanged();
    void updatedRichText();

private:
    explicit ra2snes(QObject *parent = nullptr);
    ra2snes(const ra2snes&) = delete;
    ra2snes& operator=(const ra2snes&) = delete;
    ~ra2snes();

    Usb2Snes *usb2snes;
    RAClient *raclient;
    MemoryReader *reader;
    QString m_currentGame;
    const QString m_version = RA2SNES_VERSION_STRING;
    bool loggedin;
    bool m_gameLoaded;
    bool m_loadingGame;
    bool m_customFirmware;
    bool remember_me;
    bool m_ignore;
    bool isGB;
    bool reset;
    bool updateAddresses;
    QString m_console;
    Task doThisTaskNext;
    QList<QPair<unsigned int, unsigned int>> uniqueMemoryAddresses;
    QString m_appDirPath;
    QString m_latestVersion;
    QString downloadUrl;
    QString richText;
    QTimer* crashTimer;
    QTimer* richTimer;
    void createSettingsFile();
    void loadSettings();
    void onLoginSuccess(bool r);
    void onRequestFailed(const QJsonObject& error);
    void onRequestError(const bool& net, const QString& request, const QString& error);
    void onUsb2SnesStateChanged();
    void onUsb2SnesGetAddressDataReceived();
    void onUsb2SnesGetAddressesDataReceived();
    void onUsb2SnesGetConfigDataReceived();
    void onUsb2SnesGetFileDataReceived();
    void onUsb2SnesGetNMIDataReceived();
    void onUsb2SnesInfoDone(Usb2Snes::DeviceInfo infos);
    void setCurrentConsole();
    void checkForUpdate();
    void initVars();
    void postTelemetryData();
    void updateRichText(const QString& rt);
    QTimer* waitTimer;
    QElapsedTimer* frameTimer;
    unsigned int programTime;
    unsigned int vgetTime;
};

#endif // RA2SNES_H
