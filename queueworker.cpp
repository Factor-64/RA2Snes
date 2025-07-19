#include "queueworker.h"
#include <QTimer>

QueueWorker::QueueWorker(QObject *parent)
    : QObject(parent) {}

QueueWorker::~QueueWorker() {
    stop();
}

void QueueWorker::enqueueRequest(const RequestData &data) {
    QMutexLocker locker(&mutex);
    queue.enqueue(data);
    QTimer::singleShot(0, this, [this] { runQueue(); });
}

void QueueWorker::runQueue() {
    QMutexLocker locker(&mutex);
    if (queue.isEmpty())
    {
        emit queueEmpty();
        return;
    }

    RequestData data = queue.dequeue();
    emit processRequest(data);

    if (!queue.isEmpty())
        QTimer::singleShot(0, this, [this] { runQueue(); });
}

void QueueWorker::stop() {
    QMutexLocker locker(&mutex);
    queue.clear();
}
