/*
    This file is part of the SaveState2snes software
    Copyright (C) 2017  Sylvain "Skarsnik" Colinet <scolinet@gmail.com>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef USB2SNES_H
#define USB2SNES_H

#include <QObject>
#include <QtWebSockets/QtWebSockets>


#define USB2SNESLEGACYURL "ws://localhost:8080/"
#define USB2SNESURL "ws://localhost:23074"

class Usb2Snes : public QObject
{
    Q_OBJECT
public:
    enum Space
    {
        SNES,
        CMD
    };
    enum State {
        None,
        Connected,
        Ready,
        SendingFile,
        ReceivingFile,
        GettingAddress,
        GettingAddresses,
        CheckingReset,
        GettingInfo,
        GettingConfig,
        GettingRomType,
        GettingRamSize,
        GettingNMIData,
        SettingUpVectors
    };
    enum sd2snesState {
        sd2menu,
        RomRunning
    };
    struct FileInfo {
        QString name;
        bool    dir;
    };
    struct DeviceInfo {
        QString firmwareVersion;
        QString versionString;
        QString romPlaying;
        QStringList flags;
    };

    Q_ENUM(State)
    Q_ENUM(sd2snesState)
    // Should be private, but allow for Qt to register the enum
    enum InternalState {
        INone,
        IConnected,
        DeviceListRequested,
        AttachSent,
        FirmwareVersionRequested,
        ServerVersionRequested,
        IWaitingFileSize,
        IReady,
        IBusy
    };
    Q_ENUM(InternalState)

    enum Usb2SnesCommand {
        DeviceList,
        Attach,
        AppVersion,
        Name,
        Close,
        Info,
        Boot,
        Menu,
        Reset,
        GetAddress,
        PutAddress,
        PutIPS,
        GetFile,
        PutFile,
        List,
        Remove,
        Rename,
        MakeDir
    };
    Q_ENUM(Usb2SnesCommand)

    Usb2Snes(bool autoAttach = true);
    void                    usePort(QString port);
    QString                 port();
    QString                 getRomName();
    void                    connect();
    void                    close();
    void                    setAppName(QString name);
    void                    attach(QString deviceName);
    QByteArray              getAddressSync(unsigned int addr, unsigned int size, Space space);
    void                    getAddress(unsigned int addr, unsigned int size, Space space = SNES);
    void                    getAddresses(QList<QPair<unsigned int, unsigned int>> addresses);
    void                    setAddress(unsigned int addr, QByteArray data, Space space = SNES);
    void                    checkReset();
    void                    sendFile(QString path, QByteArray data);
    void                    getFile(QString path);
    void                    renameFile(QString oldPath, QString newPath);
    void                    deleteFile(QString fileName);
    void                    boot(QString path);
    void                    mkdir(QString dirPath);
    void                    reset();
    void                    menu();
    State                   state();
    void                    infos(bool f = false);
    int                     fileDataSize() const;
    void                    ls(QString path);
    QString                 firmwareString();
    QVersionNumber          firmwareVersion();
    void                    deviceList();
    QVersionNumber          serverVersion();
    bool                    patchROM(QString patch);
    QByteArray              getBinaryData();
    void                    getConfig();
    void                    isPatchedROM();
    void                    getRomType();
    void                    getRamSize();
    unsigned int            getRomTypeData();
    unsigned int            getRamSizeData();
    void                    clearBinaryData();
    void                    setReciever();
    void                    unsetReciever();
    void                    getNMIData();
    void                    setNMIDataSize(unsigned int size);
    void                    setupNMIVectors();

signals:
    void    stateChanged();
    void    connected();
    void    disconnected();
    void    binaryMessageReceived();
    void    textMessageReceived();
    void    romStarted();
    void    menuStarted();
    void    fileSendProgress(int size);
    void    fileSent();
    void    getFileSizeGet(unsigned int);
    void    getFileDataReceived();
    void    getAddressGet(QByteArray data);
    void    getAddressDataReceived();
    void    getAddressesDataReceived();
    void    deviceListDone(QStringList listDevice);
    void    infoDone(Usb2Snes::DeviceInfo info);
    void    lsDone(QList<Usb2Snes::FileInfo> filesInfo);
    void    getConfigDataReceived();
    void    gotServerVersion();
    void    getRomTypeDataReceived();
    void    getRamSizeDataReceived();
    void    retryRomType();
    void    recieverDataReceived();
    void    getNMIDataReceived();

private slots:
    void    onWebSocketConnected();
    void    onWebSocketDisconnected();
    void    onWebSocketTextReceived(QString message);
    void    onWebSocketBinaryReceived(QByteArray message);
    void    onWebSocketError(QAbstractSocket::SocketError err);
    void    onTimerTick();

private:
    bool            m_autoAttach;
    QWebSocket      m_webSocket;
    QString         m_port;
    State           m_state;
    sd2snesState    m_sd2snesState;
    QVersionNumber  m_firmwareVersion;
    QString         m_firmwareString;
    QVersionNumber  m_serverVersion;
    InternalState   m_istate;
    QStringList     m_deviceList;
    int             m_fileSize;
    unsigned int    binaryDataSent;
    Usb2SnesCommand m_currentCommand;
    QByteArray      lastBinaryMessage;
    QString         lastTextMessage;
    unsigned int    requestedBinaryReadSize;
    QMetaEnum       metaCommands;
    unsigned int    romType;
    unsigned int    ramSize;
    unsigned int    nmiDataSize;

    QByteArray      fileDataToSend;

    QTimer          timer;

    void            sendRequest(Usb2SnesCommand opCode, QStringList operands = QStringList(), Space = SNES, QStringList flags = QStringList());
    void            changeState(State s);
    void            startSyncCall();
    void            endSyncCall();

    QStringList     getJsonResults(QString json);

};

#endif // USB2SNES_H
