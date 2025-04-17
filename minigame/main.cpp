#include <QApplication>
#include "puzzlewidget.h"

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);

    PuzzleWidget puzzle;
    puzzle.setWindowTitle("Девятки");
    puzzle.show();

    return app.exec();
}
