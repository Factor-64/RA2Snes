#ifndef QUEUEWORKER_H
#define QUEUEWORKER_H

#include <QObject>
#include <QQueue>
#include <QMutex>
#include <QDateTime>
#include "rastructs.h"

class QueueWorker : public QObject {
    Q_OBJECT

public:
    explicit QueueWorker(QObject *parent = nullptr);
    ~QueueWorker();

    void enqueueRequest(const RequestData& data);
    void stop();

signals:
    void processRequest(const RequestData& data);
    void queueEmpty();

public slots:
    void runQueue();

private:
    QQueue<RequestData> queue;
    QMutex mutex;
};

#endif // QUEUEWORKER_H
