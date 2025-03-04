import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    visible: true
    width: 400
    height: 300
    title: "Форма подсчета"

    // Основной контейнер
    Column {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // Заголовки колонок
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20

            Text {
                text: "Миша"
                font.bold: true
                font.pixelSize: 16
            }

            Text {
                text: "Саша"
                font.bold: true
                font.pixelSize: 16
            }
        }

        // Яблоки
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20

            Column {
                spacing: 5

                Text {
                    text: "Яблоки"
                }

                TextField {
                    id: mishaApples
                    width: 80
                    placeholderText: "Введите количество"
                    validator: IntValidator { bottom: 0 } // Только целые числа >= 0
                    onAccepted: validateInputs() // Проверка при нажатии Enter
                }

                Text {
                    id: mishaApplesError
                    text: ""
                    color: "red"
                    visible: false
                }
            }

            Column {
                spacing: 5

                Text {
                    text: "Яблоки"
                }

                TextField {
                    id: sashaApples
                    width: 80
                    placeholderText: "Введите количество"
                    validator: IntValidator { bottom: 0 } // Только целые числа >= 0
                    onAccepted: validateInputs() // Проверка при нажатии Enter
                }

                Text {
                    id: sashaApplesError
                    text: ""
                    color: "red"
                    visible: false
                }
            }
        }

        // Груши
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20

            Column {
                spacing: 5

                Text {
                    text: "Груши"
                }

                TextField {
                    id: mishaPears
                    width: 80
                    placeholderText: "Введите количество"
                    validator: IntValidator { bottom: 0 } // Только целые числа >= 0
                    onAccepted: validateInputs() // Проверка при нажатии Enter
                }

                Text {
                    id: mishaPearsError
                    text: ""
                    color: "red"
                    visible: false
                }
            }

            Column {
                spacing: 5

                Text {
                    text: "Груши"
                }

                TextField {
                    id: sashaPears
                    width: 80
                    placeholderText: "Введите количество"
                    validator: IntValidator { bottom: 0 } // Только целые числа >= 0
                    onAccepted: validateInputs() // Проверка при нажатии Enter
                }

                Text {
                    id: sashaPearsError
                    text: ""
                    color: "red"
                    visible: false
                }
            }
        }

        // Кнопки
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            Button {
                text: "Счет"
                width: 80
                onClicked: calculateTotal()
            }

            Button {
                text: "Сброс"
                width: 80
                onClicked: resetForm()
            }
        }

        // Результат
        Row {
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                id: resultText
                text: ""
                visible: false
                font.pixelSize: 14
                color: "green"
                horizontalAlignment: Text.AlignHCenter
            }
        }

    }

    // Функция проверки ввода
    function validateInputs() {
        let isValid = true;

        function checkField(field, errorLabel) {
            if (field.text === "" || parseInt(field.text) < 0) {
                errorLabel.text = "Неверное значение";
                errorLabel.visible = true;
                return false;
            } else {
                errorLabel.text = "";
                errorLabel.visible = false;
                return true;
            }
        }

        isValid = checkField(mishaApples, mishaApplesError) && isValid;
        isValid = checkField(sashaApples, sashaApplesError) && isValid;
        isValid = checkField(mishaPears, mishaPearsError) && isValid;
        isValid = checkField(sashaPears, sashaPearsError) && isValid;

        return isValid;
    }

    // Функция подсчета
    function calculateTotal() {
        if (validateInputs()) {
            let totalApples = parseInt(mishaApples.text) + parseInt(sashaApples.text);
            let totalPears = parseInt(mishaPears.text) + parseInt(sashaPears.text);

            // Блокировка полей
            mishaApples.enabled = false;
            sashaApples.enabled = false;
            mishaPears.enabled = false;
            sashaPears.enabled = false;

            // Отображение результата
            resultText.text = `Всего яблок ${totalApples}, а груш ${totalPears}`;
            resultText.visible = true;
        }
    }

    // Функция сброса
    function resetForm() {
        mishaApples.text = "";
        sashaApples.text = "";
        mishaPears.text = "";
        sashaPears.text = "";

        mishaApples.enabled = true;
        sashaApples.enabled = true;
        mishaPears.enabled = true;
        sashaPears.enabled = true;

        mishaApplesError.text = "";
        sashaApplesError.text = "";
        mishaPearsError.text = "";
        sashaPearsError.text = "";

        mishaApplesError.visible = false;
        sashaApplesError.visible = false;
        mishaPearsError.visible = false;
        sashaPearsError.visible = false;

        resultText.text = "";
        resultText.visible = false;
    }
}
