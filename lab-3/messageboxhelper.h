#ifndef MESSAGEBOXHELPER_H
#define MESSAGEBOXHELPER_H

#include <QObject>
#include <QMessageBox>

class MessageBoxHelper : public QObject {
    Q_OBJECT

public:
    explicit MessageBoxHelper(QObject *parent = nullptr) : QObject(parent) {}

public slots:
    void showInfo(const QString &message) {
        if (message.isEmpty()) {
            qWarning() << "Попытка показать пустое сообщение!";
            return;
        }
        try {
            QMessageBox::information(nullptr, "Информация", message);
        } catch (const std::exception &e) {
            qCritical() << "Ошибка при показе сообщения:" << e.what();
        } catch (...) {
            qCritical() << "Неизвестная ошибка при показе сообщения.";
        }
    }
};

#endif // MESSAGEBOXHELPER_H
