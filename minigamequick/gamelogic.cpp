#include "gamelogic.h"
#include <QVariant>

GameLogic::GameLogic(QObject *parent) : QObject(parent) {
    m_tiles = {1, 2, 3, 4, 5, 6, 7, 8, 0};
    std::shuffle(m_tiles.begin(), m_tiles.end(), QRandomGenerator::global()->generate());

    emptyIndex = m_tiles.indexOf(0);
}

QVariantList GameLogic::tiles() const {
    QVariantList list;
    for (int val : m_tiles)
        list.append(QVariant(val));
         // исправлено
    return list;
}

QString GameLogic::tileText(int index) const {
    int value = m_tiles[index];
    return value == 0 ? "" : QString::number(value);
}

bool GameLogic::isSelected(int index) const {
    return index == selectedIndex;
}

void GameLogic::selectTile(int index) {
    if (selectedIndex == -1 && m_tiles[index] != 0) {
        selectedIndex = index;
        emit tilesChanged();
    } else if (index == selectedIndex || m_tiles[index] != 0) {
        if (isAdjacent(index, selectedIndex)) {
            std::swap(m_tiles[index], m_tiles[selectedIndex]);
            emptyIndex = selectedIndex;
            selectedIndex = -1;

            emit tilesChanged();
            if (isSolved()) {
                m_tiles[emptyIndex] = 9;
                emit tilesChanged();
                emit gameWon();
            }
        } else {
            selectedIndex = -1;
            emit tilesChanged();
        }
    } else {
        selectedIndex = -1;
        emit tilesChanged();
    }
}

bool GameLogic::isAdjacent(int a, int b) const {
    int r1 = a / 3, c1 = a % 3;
    int r2 = b / 3, c2 = b % 3;
    return (qAbs(r1 - r2) + qAbs(c1 - c2)) == 1;
}

bool GameLogic::isSolved() const {
    for (int i = 0; i < 8; ++i) {
        if (m_tiles[i] != i + 1)
            return false;
    }
    return m_tiles[8] == 0;
}
