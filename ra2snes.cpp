#include "ra2snes.h"
#include "./ui_ra2snes.h"
#include <QMessageBox>
#include <QCryptographicHash>
#include "ra_client.h"
#include "usb2snes.h"
#include "rc_client.h"

ra2snes::ra2snes(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::ra2snes)
{
    ui->setupUi(this);
    ui->profile->setEnabled(false);
    ui->profile->setVisible(false);

    currentGame = "/sd2snes/m3nu.bin";
    usb2snes = new Usb2Snes(false);

    initialize_retroachievements_client();

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
            usb2snes->attach(devices.at(0));
        else
        {
            QTimer::singleShot(1000, this, [=] {
                if (usb2snes->state() == Usb2Snes::Connected)
                    usb2snes->deviceList();
            });
        }
    });

    connect(usb2snes, &Usb2Snes::infoDone, this, [=] (Usb2Snes::DeviceInfo infos) {
        bool gameLoaded = rc_client_is_game_loaded(g_client);
        if (infos.flags.contains("NO_FILE_CMD"))
        {
            QMessageBox::information(this, tr("Device error"), tr("The device does not support file operation"));
        }
        else
        {
            currentGame = infos.romPlaying.remove(QChar('\u0000'));
            ui->currentGame->setText(QString(tr("Firmware version : %1 - Rom Playing : %2")).arg(infos.firmwareVersion, currentGame));
            if(currentGame.contains("m3nu.bin"))
            {
                if(gameLoaded)
                {
                    rc_client_unload_game(g_client);
                    gameLoaded = false;
                }
                usb2snes->checkReset();
            }
            else
            {
                if(!gameLoaded && loggedin)
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
                            if(currentGame.contains(".gb"))
                                load_gameboy_game(romData, *fileSize);
                            else
                                load_snes_game(romData, *fileSize);
                        }
                    });
                }
                else
                    QTimer::singleShot(0, this, [=] {
                        readMemoryCount = 0;
                        rc_client_do_frame(g_client);
                    });
            }
        }
    });

    QTimer::singleShot(0, this, [=] {
        usb2snes->connect();
    });

    //frameTimer = new QTimer(this);
    //connect(frameTimer, &QTimer::timeout, this, &ra2snes::processFrame);
    //frameTimer->start(1000);
}

ra2snes::~ra2snes()
{
    delete ui;
}

void ra2snes::processFrame()
{
    qDebug() << "Process" << rc_client_is_processing_required(g_client);
}

void ra2snes::on_signin_button_clicked()
{
    QString username = ui->username_input->text();
    QString password = ui->password_input->text();

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
        rc_client_do_frame(g_client);
    }
    else if(usb2snes->state() == Usb2Snes::ReceivingFile)
        qDebug() << "Receiving File";
    else if(usb2snes->state() == Usb2Snes::GettingAddress)
        qDebug() << "Getting Address";
}
