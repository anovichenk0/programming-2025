import QtQuick 6.5
import QtQuick.Controls 6.5

ApplicationWindow {
    visible: true
    width: 320
    height: 420
    title: "Девятки (Пятнашки)"

    readonly property int gridSize: 3
    readonly property int cellSize: 100

    // Массив плиток: 1-8 и 0 (пустая)
    property var tiles: [1, 2, 3, 4, 5, 6, 7, 8, 0]
    property int emptyIndex: tiles.indexOf(0)
    property bool isWin: false // Глобальная переменная для проверки победы

    // Счетчики шагов и перетасовок
    property int moveCount: 0
    property int winCount: 0
    property int shuffleCount: 0

    function indexToRowCol(index) {
        return { row: Math.floor(index / gridSize), col: index % gridSize }
    }

    function rowColToIndex(row, col) {
        return row * gridSize + col
    }

    function move(index) {
        if (isWin) return; // Если победа, не разрешать движение

        const pos = indexToRowCol(index)
        const emptyPos = indexToRowCol(emptyIndex)

        const isNeighbor = Math.abs(pos.row - emptyPos.row) + Math.abs(pos.col - emptyPos.col) === 1

        if (isNeighbor) {
            // Меняем местами
            let temp = tiles[index]
            tiles[index] = tiles[emptyIndex]
            tiles[emptyIndex] = temp

            emptyIndex = index
            tilesChanged()
            moveCount++ // Увеличиваем счетчик шагов
            const win = checkWin()

            if (win) {
                isWin = true
                tiles[emptyIndex] = 9 // Заменить пустую ячейку на "9"
                tilesChanged()
                console.log("Победа!")
                showWinMessage()
            }
        }
    }

    function checkWin() {
        for (let i = 0; i < 8; i++) {
            if (tiles[i] !== i + 1)
                return false
        }
        winCount++
        return true
    }

    function shuffle() {
        if (isWin) return; // Если победа, не перемешивать

        // Перемешиваем и гарантируем наличие пустой ячейки
        do {
            tiles = tiles.sort(() => Math.random() - 0.5)
            emptyIndex = tiles.indexOf(0)
        } while (!isSolvable(tiles))

        shuffleCount++ // Увеличиваем счетчик перетасовок
        moveCount = 0
        tilesChanged()
    }

    // Проверка на решаемость (для 3x3)
    function isSolvable(arr) {
        let invCount = 0
        for (let i = 0; i < 8; i++) {
            for (let j = i + 1; j < 9; j++) {
                if (arr[i] && arr[j] && arr[i] > arr[j])
                    invCount++
            }
        }
        return invCount % 2 === 0
    }

    // Показать сообщение о победе и перетасовать плитки спустя несколько секунд
    function showWinMessage() {
        // Блокируем перемещение плиток и показываем сообщение
        messageText.text = "Победа!"

        // Таймер для удаления лишней плитки и перетасовки плиток через несколько секунд
        timer.start()
    }

    // Таймер для удаления плитки и перетасовки плиток
    Timer {
        id: timer
        interval: 2000 // 2 секунды
        running: false
        repeat: false
        onTriggered: {
            // Удаляем лишнюю плитку (заменяем "9" на 0)
            tiles[emptyIndex] = 0
            tilesChanged()

            // Перемешиваем плитки для следующей игры
            shuffle()

            // Сбрасываем победное состояние
            isWin = false
            messageText.text = ""
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 10

        Grid {
            id: gameGrid
            rows: gridSize
            columns: gridSize
            spacing: 4

            Repeater {
                model: 9

                Rectangle {
                    width: cellSize
                    height: cellSize
                    color: tiles[index] === 0 ? "#cccccc" : "white"
                    border.color: "black"
                    border.width: 2

                    Text {
                        anchors.centerIn: parent
                        text: tiles[index] !== 0 ? tiles[index] : ""
                        font.pixelSize: 30
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: move(index)
                    }
                }
            }
        }

        // Отображение кнопки перемешивания
        Button {
            text: "Перемешать"
            onClicked: shuffle()
        }

        // Отображение сообщения о победе
        Text {
            id: messageText
            anchors.horizontalCenter: parent.horizontalCenter
            text: ""
            font.pixelSize: 20
            color: "green"
        }

        // Панель с информацией о счетчиках
        Row {
            spacing: 20
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                text: "Шаги: " + moveCount
                font.pixelSize: 18
            }

            Text {
                text: "Перетасовки: " + shuffleCount
                font.pixelSize: 18
            }

            Text {
                text: "Победы: " + winCount
                font.pixelSize: 18
            }
        }
    }
}
