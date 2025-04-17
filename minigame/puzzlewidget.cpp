#include "puzzlewidget.h"
#include <QMessageBox>
#include <QRandomGenerator>
#include <QFile>
#include <QTextStream>

PuzzleWidget::PuzzleWidget(QWidget *parent)
    : QWidget(parent), grid(new QGridLayout(this)) {
    setFixedSize(300, 300);
    setLayout(grid);

    for (int i = 0; i < 9; ++i) {
        auto btn = new QPushButton(this);
        btn->setFixedSize(90, 90);
        btn->setStyleSheet("font-size: 24px;");
        connect(btn, &QPushButton::clicked, this, &PuzzleWidget::handleButtonClick);
        buttons.append(btn);
        grid->addWidget(btn, i / 3, i % 3);
    }

    shuffle();
    updateButtons();
}

PuzzleWidget::~PuzzleWidget() {}

void PuzzleWidget::shuffle() {
    QVector<int> values = {1, 2, 3, 4, 5, 6, 7, 8, 0}; // 0 = пустая ячейка

    // Можно вместо рандома загружать из файла
    std::shuffle(values.begin(), values.end(), QRandomGenerator::global()->generate());

    for (int i = 0; i < 9; ++i) {
        if (values[i] == 0) emptyIndex = i;
        buttons[i]->setText(values[i] == 0 ? "" : QString::number(values[i]));
    }
}

void PuzzleWidget::updateButtons() {
    for (int i = 0; i < 9; ++i) {
        buttons[i]->setStyleSheet("font-size: 24px;");
    }
    if (selectedIndex != -1)
        buttons[selectedIndex]->setStyleSheet("background-color: yellow; font-size: 24px;");
}

void PuzzleWidget::handleButtonClick() {
    QPushButton* clicked = qobject_cast<QPushButton*>(sender());
    int index = buttons.indexOf(clicked);

    if (selectedIndex == -1) {
        if (index == emptyIndex) return;
        selectedIndex = index;
    } else {
        if (index == selectedIndex || !isAdjacent(index, selectedIndex)) {
            selectedIndex = -1;
            updateButtons();
            return;
        }

        if (index == emptyIndex || selectedIndex == emptyIndex) {
            buttons[emptyIndex]->setText(buttons[selectedIndex]->text());
            buttons[selectedIndex]->setText("");
            emptyIndex = selectedIndex;
        }

        selectedIndex = -1;
        updateButtons();

        if (isSolved()) {
            finalizeGame();
        }
    }

    updateButtons();
}

bool PuzzleWidget::isAdjacent(int i1, int i2) const {
    int r1 = i1 / 3, c1 = i1 % 3;
    int r2 = i2 / 3, c2 = i2 % 3;
    return (qAbs(r1 - r2) + qAbs(c1 - c2)) == 1;
}

bool PuzzleWidget::isSolved() const {
    for (int i = 0; i < 8; ++i) {
        if (buttons[i]->text() != QString::number(i + 1))
            return false;
    }
    return buttons[8]->text().isEmpty();
}

void PuzzleWidget::finalizeGame() {
    buttons[emptyIndex]->setText("9");
    for (auto btn : buttons) {
        btn->setEnabled(false);
    }

    QMessageBox::information(this, "Победа!", "Вы решили головоломку!");
}
