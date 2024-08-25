#include "ra2snes.h"
#include "./ui_ra2snes.h"
#include "usb2snes.h"

#include <QDebug>

#include <QFileDialog>
#include <QMessageBox>
#include <QStorageInfo>

#include <QStandardPaths>
#include <QModelIndex>
#include <QDir>
#include <QInputDialog>
#include <QRegularExpression>
#include <QCryptographicHash>

Usb2Snes* usb2snes;

ra2snes::ra2snes(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::ra2snes)
{
    ui->setupUi(this);
    ui->profile->setEnabled(false);
    ui->profile->setVisible(false);
    usb2snes = new Usb2Snes(false);
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
            refreshStatus();
        } else {
            QTimer::singleShot(1000, this, [=] {
                if (usb2snes->state() == Usb2Snes::Connected)
                    usb2snes->deviceList();
            });
        }
    });

    connect(usb2snes, &Usb2Snes::infoDone, this, [=] (Usb2Snes::DeviceInfo infos) {
        QString path = QString(infos.romPlaying);
        path = path.left(path.lastIndexOf(".") + 4);
        qDebug() << path;
        ui->currentRom->setText(path);
        if (infos.flags.contains("NO_FILE_CMD"))
        {
            qDebug() << "The device does not support file operation";
        }
        else
            getFileMD5(path);
    });

    QTimer::singleShot(0, this, [=] {
        usb2snes->connect();
    });
}

ra2snes::~ra2snes()
{
    delete ui;
}

void ra2snes::on_signin_button_clicked()
{
    QString username = ui->username_input->text();
    QString password = ui->password_input->text();
    if(true)
    {
        if(ui->remember->isChecked())
        {
            qDebug() << "Saved";
        }
        QMessageBox::warning(this, "Login", "Correct");
        ui->signin_group->setEnabled(false);
        ui->signin_group->setVisible(false);
        resizeWindow(600,1000);
        ui->profile->setEnabled(true);
        ui->profile->setVisible(true);
    }
    else
    {
        QMessageBox::warning(this, "Login", "Incorrect");
    }
}

void ra2snes::resizeWindow(int width, int height)
{
    this->resize(width, height);
}

void ra2snes::refreshStatus()
{
    usb2snes->infos();
}

void ra2snes::getFileMD5(const QString& path)
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
}
