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

ra2snes::ra2snes(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::ra2snes)
{
    ui->setupUi(this);
    ui->profile->setEnabled(false);
    ui->profile->setVisible(false);
    Usb2Snes snes;
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
