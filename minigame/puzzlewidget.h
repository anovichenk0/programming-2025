#ifndef PUZZLEWIDGET_H
#define PUZZLEWIDGET_H

#include <QWidget>
#include <QPushButton>
#include <QVector>
#include <QGridLayout>

class PuzzleWidget : public QWidget {
    Q_OBJECT

public:
    PuzzleWidget(QWidget *parent = nullptr);
    ~PuzzleWidget();

private slots:
    void handleButtonClick();

private:
    QVector<QPushButton*> buttons;
    QGridLayout* grid;
    int emptyIndex;
    int selectedIndex = -1;

    void shuffle();
    void updateButtons();
    bool isAdjacent(int index1, int index2) const;
    bool isSolved() const;
    void finalizeGame();
};

#endif // PUZZLEWIDGET_H
