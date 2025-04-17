import QtQuick 6.5
import QtQuick.Controls 6.5

ApplicationWindow {
    visible: true
    width: 320
    height: 460
    title: "Девятки (Пятнашки с изображением)"

    readonly property int gridSize: 3
    readonly property int cellSize: 100

    property var tiles: [1, 2, 3, 4, 5, 6, 7, 0, 8]
    property int emptyIndex: tiles.indexOf(0)
    property bool isWin: false

    property int moveCount: 0
    property int winCount: 0
    property int shuffleCount: 0

    function indexToRowCol(index) {
        return { row: Math.floor(index / gridSize), col: index % gridSize }
    }

    function move(index) {
        if (isWin) return

        const pos = indexToRowCol(index)
        const emptyPos = indexToRowCol(emptyIndex)

        const isNeighbor = Math.abs(pos.row - emptyPos.row) + Math.abs(pos.col - emptyPos.col) === 1

        if (isNeighbor) {
            let temp = tiles[index]
            tiles[index] = tiles[emptyIndex]
            tiles[emptyIndex] = temp

            emptyIndex = index
            tilesChanged()
            moveCount++

            if (checkWin()) {
                isWin = true
                tiles[emptyIndex] = 9
                tilesChanged()
                winCount++
                messageText.text = "Победа!"
                timer.start()
            }
        }
    }

    function checkWin() {
        for (let i = 0; i < 8; i++) {
            if (tiles[i] !== i + 1)
                return false
        }
        return true
    }

    function shuffle() {
        if (isWin) return

        do {
            tiles = tiles.sort(() => Math.random() - 0.5)
            emptyIndex = tiles.indexOf(0)
        } while (!isSolvable(tiles))

        shuffleCount++
        moveCount = 0
        tilesChanged()
    }

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

    Timer {
        id: timer
        interval: 2000
        running: false
        repeat: false
        onTriggered: {
            tiles[emptyIndex] = 0
            tilesChanged()
            isWin = false
            messageText.text = ""
            shuffle()
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
                    border.width: 1
                    clip: true

                    Image {
                        anchors.fill: parent
                        visible: tiles[index] !== 0
                        source: "qrc:/puzzle.jpg"
                        fillMode: Image.PreserveAspectCrop
                        sourceSize.width: cellSize * gridSize
                        sourceSize.height: cellSize * gridSize
                        sourceClipRect: Qt.rect(
                            ((tiles[index] - 1) % gridSize) * cellSize,
                            Math.floor((tiles[index] - 1) / gridSize) * cellSize,
                            cellSize,
                            cellSize
                        )
                        onStatusChanged: console.log("Image status:", status)
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: move(index)
                    }
                }
            }
        }

        Button {
            text: "Перемешать"
            onClicked: shuffle()
        }

        Text {
            id: messageText
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 20
            color: "green"
        }

        Row {
            spacing: 15
            anchors.horizontalCenter: parent.horizontalCenter

            Text { text: "Шаги: " + moveCount; font.pixelSize: 16 }
            Text { text: "Перетасовки: " + shuffleCount; font.pixelSize: 16 }
            Text { text: "Победы: " + winCount; font.pixelSize: 16 }
        }
    }
}
