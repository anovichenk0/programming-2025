#ifndef GAMELOGIC_H
#define GAMELOGIC_H

#include <QObject>
#include <QVector>
#include <QRandomGenerator>

class GameLogic : public QObject {
    Q_OBJECT
    Q_PROPERTY(QVariantList tiles READ tiles NOTIFY tilesChanged)

public:
    explicit GameLogic(QObject *parent = nullptr);
    Q_INVOKABLE void selectTile(int index);
    Q_INVOKABLE bool isSelected(int index) const;
    Q_INVOKABLE QString tileText(int index) const;

    QVariantList tiles() const;

signals:
    void tilesChanged();
    void gameWon();

private:
    QVector<int> m_tiles; // 0 = пустая
    int emptyIndex;
    int selectedIndex = -1;

    bool isAdjacent(int a, int b) const;
    bool isSolved() const;
};

#endif // GAMELOGIC_H
