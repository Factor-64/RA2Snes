#ifndef RA2SNES_H
#define RA2SNES_H

#include <QMainWindow>
#include <QTimer>
#include "usb2snes.h"

QT_BEGIN_NAMESPACE
namespace Ui {
class ra2snes;
}
QT_END_NAMESPACE

class ra2snes : public QMainWindow
{
    Q_OBJECT

public:
    ra2snes(QWidget *parent = nullptr);
    ~ra2snes();

private slots:
    void on_signin_button_clicked();
    void processFrame();

signals:
    void operationComplete();

private:
    Ui::ra2snes *ui;
    Usb2Snes* usb2snes;
    QString currentGame;
    bool loggedin;
    bool gameLoaded;
    bool isGB;
    QTimer *frameTimer;

    void resizeWindow(int width, int height);
    void refreshStatus();
    void onUsb2SnesStateChange();
};
#endif // RA2SNES_H
