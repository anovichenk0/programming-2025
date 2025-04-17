import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15


// Окно должно быть фиксированного размера (под вопросом)
// Размер плюсика можно менять
// Пока все.

ApplicationWindow {
    visible: true
    width: 400
    height: 400
    title: "Point Movement Example"
    flags: Qt.Window | Qt.CustomizeWindowHint | Qt.WindowTitleHint | Qt.WindowCloseButtonHint

    // Ограничения размеров окна
    property int windowWidth: width
    property int windowHeight: height

    // Начальное положение точки
    property int startPointX: 200
    property int startPointY: 200

    // Текущие координаты центра точки
    property int pointX: startPointX
    property int pointY: startPointY

    // Размер точки
    property int pointSize: 200

    // Минимальные и максимальные границы для точки
    property int minX: pointSize / 2
    property int maxX: windowWidth - pointSize / 2
    property int minY: pointSize / 2
    property int maxY: windowHeight - pointSize / 2

    // Флаги для кнопок
    property bool canMoveUp: pointY > minY
    property bool canMoveDown: pointY < maxY
    property bool canMoveLeft: pointX > minX
    property bool canMoveRight: pointX < maxX

    // Метка для отображения координат
    Text {
        text: "Position: (" + pointX + ", " + pointY + ")"
        font.pixelSize: 16
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 10
    }

    Text {
        text: "Лабораторная работа №3. Андрея Новиченко"
        font.pixelSize: 16
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 30
    }

    // Главный контейнер для кнопок
    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 55
        spacing: 10

        // Верхняя строка с кнопкой "Вверх"
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 10

            Item {
                Layout.fillWidth: true
            }

            Button {
                id: upButton
                text: "Вверх"
                enabled: canMoveUp
                onClicked: {
                    pointY = Math.max(pointY - 10, minY)
                    updateMovementFlags()
                }
            }

            Item {
                Layout.fillWidth: true
            }
        }

        // Средняя строка с кнопками "Влево", "Инфо" и "Вправо"
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 10

            Button {
                id: leftButton
                text: "Влево"
                enabled: canMoveLeft
                onClicked: {
                    pointX = Math.max(pointX - 10, minX)
                    updateMovementFlags()
                }
            }

            Button {
                id: infoButton
                text: "Инфо"
                onClicked: {
                    let deltaX = pointX - startPointX
                    let deltaY = pointY - startPointY
                    let message = "Положение (" + pointX + "; " + pointY + ")\n" +
                                  "Отклонение (X: " + (deltaX >= 0 ? "+" : "") + deltaX + "; Y: " + (deltaY >= 0 ? "+" : "") + deltaY + ")"
                    try {
                        messageBoxHelper.showInfo(message) // Вызов C++ метода
                    } catch (e) {
                        console.error(e)
                    }
                }
            }

            Button {
                id: rightButton
                text: "Вправо"
                enabled: canMoveRight
                onClicked: {
                    pointX = Math.min(pointX + 10, maxX)
                    updateMovementFlags()
                }
            }
        }

        // Нижняя строка с кнопкой "Вниз"
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 10

            Item {
                Layout.fillWidth: true
            }

            Button {
                id: downButton
                text: "Вниз"
                enabled: canMoveDown
                onClicked: {
                    pointY = Math.min(pointY + 10, maxY)
                    updateMovementFlags()
                }
            }

            Item {
                Layout.fillWidth: true
            }
        }
    }

    // Точка, которая находится вне любого контейнера
    Rectangle {
        width: pointSize
        height: pointSize
        color: "red"
        x: pointX - pointSize / 2
        y: pointY - pointSize / 2
        radius: pointSize / 2

        Text {
            text: "+"
            anchors.centerIn: parent
            color: "white"
            font.pixelSize: pointSize
        }
    }

    // Обновление флагов движения
    function updateMovementFlags() {
        canMoveUp = pointY > minY
        canMoveDown = pointY < maxY
        canMoveLeft = pointX > minX
        canMoveRight = pointX < maxX

        upButton.enabled = canMoveUp
        downButton.enabled = canMoveDown
        leftButton.enabled = canMoveLeft
        rightButton.enabled = canMoveRight
    }
}
