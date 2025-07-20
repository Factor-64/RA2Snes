#ifndef MEMORYREADER_H
#define MEMORYREADER_H

#include <QObject>
#include <QList>
#include <QQueue>
#include <QMutex>
#include "rc_internal.h"
#include "rastructs.h"

class MemoryReader : public QObject {
    Q_OBJECT

public:

    explicit MemoryReader(QObject *parent = nullptr);

    void initTriggers(const QList<AchievementInfo>& achievements, const QList<LeaderboardInfo>& leaderboards, const QString& richPresence, const unsigned int& ramSize);
    void remapTriggerAddresses(bool modified);
    QList<QPair<unsigned int, unsigned int>> getUniqueMemoryAddresses();
    //void checkLeaderboards();
    void addFrameToQueues(const QByteArray& data, const unsigned int& frames);
    void clearQueue();

signals:
    void finishedMemorySetup();
    void achievementsChecked();
    void achievementUnlocked(const unsigned int& id, const QDateTime& time);
    void leaderboardsChecked();
    void leaderboardCompleted(const unsigned int& id, const QDateTime& time);
    void updateAchievementInfo(const unsigned int& id, const AchievementInfoType& infotype, const int& value);
    void modifiedAddresses(const QList<QPair<unsigned int, unsigned int>> uma);
    void updateRichPresence(const QString& status);
    void continueQueue();

private:
    void decrementAddressCounts(rc_memrefs_t& memrefs);
    void checkAchievements();
    void runQueue();
    void processFrames();
    QList<QPair<unsigned int, unsigned int>> uniqueMemoryAddresses;
    QMap<unsigned int, rc_trigger_with_memrefs_t*> achievementTriggers;
    QMap<unsigned int, rc_lboard_t*> leaderboardTriggers;
    QQueue<QPair<QByteArray, int>> frameQueue;
    QMap<unsigned int, unsigned int> uniqueMemoryAddressesCounts;
    QMap<unsigned int, unsigned int> addressMap;
    rc_richpresence_with_memrefs_t* mem_richpresence;
    QMutex frameQueueMutex;
    QMutex triggersMutex;
    QMutex uniqueAddressMutex;
    QAtomicInt rpState;
    //QQueue<QPair<QByteArray, int>> leaderboardFrames;
};


#endif // MEMORYREADER_H
