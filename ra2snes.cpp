#include "ra2snes.h"
#include "./ui_ra2snes.h"
#include <QMessageBox>
#include <QCryptographicHash>
#include "ra_client.h"

ra2snes::ra2snes(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::ra2snes)
{
    ui->setupUi(this);
    ui->profile->setEnabled(false);
    ui->profile->setVisible(false);

    usb2snes = new Usb2Snes(false);
    currentGame = "/sd2snes/m3nu.bin";
    loggedin = false;
    gameLoaded = false;

    initialize_retroachievements_client();

    connect(usb2snes, &Usb2Snes::stateChanged, this, &::ra2snes::onUsb2SnesStateChange);
    connect(usb2snes, &Usb2Snes::connected, this, [=]() {
        usb2snes->setAppName("ra2snes");
        qDebug() << "Connected to usb2snes server, trying to find a suitable device";
        usb2snes->deviceList();
    });

    connect(usb2snes, &Usb2Snes::disconnected, this, [=]() {
        qDebug() << "Disconnected, trying to reconnect in 1 sec";
        QTimer::singleShot(1000, this, [=] {
            usb2snes->connect();
        });
    });

    connect(usb2snes, &Usb2Snes::deviceListDone, this, [=] (QStringList devices) {
        if (!devices.empty())
        {
            usb2snes->attach(devices.at(0));
        }
        else
        {
            QTimer::singleShot(1000, this, [=] {
                if (usb2snes->state() == Usb2Snes::Connected)
                    usb2snes->deviceList();
            });
        }
    });
    connect(usb2snes, &Usb2Snes::infoDone, this, [=] (Usb2Snes::DeviceInfo infos) {
        if (infos.flags.contains("NO_FILE_CMD"))
        {
            QMessageBox::information(this, tr("Device error"), tr("The device does not support file operation"));
        }
        else
        {
            currentGame = infos.romPlaying.remove(QChar('\u0000'));
            ui->currentRom->setText(QString(tr("Firmware version : %1 - Rom Playing : %2")).arg(infos.firmwareVersion, currentGame));
            if(currentGame.contains("m3nu.bin"))
            {
                if(gameLoaded)
                {
                    rc_client_unload_game(g_client);
                    gameLoaded = false;
                }
                usb2snes->infos();
            }
            else
            {
                if(!gameLoaded)
                {
                    qDebug() << "Sending";
                    usb2snes->getFile(currentGame);
                    auto fileData = std::make_shared<QByteArray>();
                    auto fileSize = std::make_shared<unsigned int>();

                    connect(usb2snes, &Usb2Snes::getFileSizeGet, this, [fileSize] (unsigned int size) mutable {
                        *fileSize = size;
                    });

                    connect(usb2snes, &Usb2Snes::getFileDataGet, this, [this, fileData, fileSize] (QByteArray data) mutable {
                        fileData->append(data);
                        if(fileData->length() == *fileSize)
                        {
                            const uint8_t* romData = reinterpret_cast<const uint8_t*>(fileData->constData());
                            /*QCryptographicHash hash(QCryptographicHash::Md5);
                            QByteArrayView dataView(reinterpret_cast<const char*>(romData), *fileSize);
                            hash.addData(dataView);
                            QByteArray md5Hash = hash.result();
                            qDebug() << "Size: " << *fileSize;
                            qDebug() << "MD5 Hash:" << md5Hash.toHex();*/
                            if(currentGame.contains(".gb"))
                                load_gameboy_game(romData, *fileSize);
                            else
                                load_snes_game(romData, *fileSize);
                            gameLoaded = true;
                        }
                    });
                }
                else
                    usb2snes->infos();
            }
        }
    });

    QTimer::singleShot(0, this, [=] {
        usb2snes->connect();
    });

    frameTimer = new QTimer(this);
    connect(frameTimer, &QTimer::timeout, this, &ra2snes::processFrame);
    frameTimer->start(16);
}

ra2snes::~ra2snes()
{
    delete ui;
}

void ra2snes::processFrame()
{
    rc_client_do_frame(g_client);
}

void ra2snes::on_signin_button_clicked()
{
    QString username = ui->username_input->text();
    QString password = ui->password_input->text();
    loggedin = true;

    login_retroachievements_user(username.toStdString().c_str(), password.toStdString().c_str());
}


void ra2snes::resizeWindow(int width, int height)
{
    this->resize(width, height);
}

void ra2snes::refreshStatus()
{
    usb2snes->infos();
}

void ra2snes::onUsb2SnesStateChange()
{
    qDebug() << "State Changed" << usb2snes->state();
    if(usb2snes->state() == Usb2Snes::Ready)
    {
        usb2snes->infos();
        qDebug() << "infos";
    }
    else if(usb2snes->state() == Usb2Snes::ReceivingFile)
        qDebug() << "Receiving File";
}

/*void ra2snes::getFileMD5(const QString& path)
{
    usb2snes->getFile(path);
    auto fileData = std::make_shared<QByteArray>();
    auto fileSize = std::make_shared<unsigned int>();
    auto md5Hash = std::make_shared<QString>();
    connect(usb2snes, &Usb2Snes::getFileSizeGet, this, [fileSize] (unsigned int size) mutable {
        *fileSize = size;
    });
    connect(usb2snes, &Usb2Snes::getFileDataGet, this, [this, fileData, fileSize, md5Hash] (QByteArray data) mutable {
        fileData->append(data);
        if(fileData->length() == *fileSize)
        {
            QByteArray hash = QCryptographicHash::hash(*fileData, QCryptographicHash::Md5);
            *md5Hash = QString(hash.toHex());
            qDebug() << *md5Hash;
        }
    });
}*/
