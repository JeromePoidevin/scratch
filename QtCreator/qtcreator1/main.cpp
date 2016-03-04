#include <QtGui/QApplication>
#include <QPushButton>
#include "mainwindow.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    MainWindow win;
    win.show();

    QPushButton quit("Quit");
    quit.resize(75, 30);
    quit.setFont(QFont("Times", 18, QFont::Bold));
    QObject::connect(&quit, SIGNAL(clicked()), &app, SLOT(quit()));
    quit.show();

    return app.exec();
}
