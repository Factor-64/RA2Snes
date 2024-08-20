#include "ra2snes.h"
#include "./ui_ra2snes.h"

ra2snes::ra2snes(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::ra2snes)
{
    ui->setupUi(this);
}

ra2snes::~ra2snes()
{
    delete ui;
}
