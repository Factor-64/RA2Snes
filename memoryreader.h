#ifndef MEMORYREADER_H
#define MEMORYREADER_H

#include <QObject>
#include <QList>
#include <QQueue>
#include "rc_runtime_types.h"
#include "rastructs.h"

class MemoryReader : public QObject {
    Q_OBJECT

public:

    explicit MemoryReader(QObject *parent = nullptr);

    void initTriggers(const QList<AchievementInfo>& achievements, const QList<LeaderboardInfo>& leaderboards, const unsigned int& ramSize);
    void remapTriggerAddresses();
    QList<QPair<int, int>> getUniqueMemoryAddresses();
    void checkAchievements();
    //void checkLeaderboards();
    void addFrameToQueues(const QByteArray& data, const int& frames);
    int achievementQueueSize();
    void clearQueue();

signals:
    void finishedMemorySetup();
    void achievementsChecked();
    void achievementUnlocked(const unsigned int& id, const QDateTime& time);
    void leaderboardsChecked();
    void leaderboardCompleted(const unsigned int& id, const QDateTime& time);
    void updateAchievementInfo(const unsigned int& id, const AchievementInfoType& infotype, const int& value);
    void modifiedAddresses();

private:
    void decrementAddressCounts(rc_memref_t* nextref);
    QList<QPair<int, int>> uniqueMemoryAddresses;
    QMap<unsigned int, rc_trigger_t*> achievementTriggers;
    QMap<unsigned int, rc_lboard_t*> leaderboardTriggers;
    QQueue<QPair<QByteArray, int>> achievementFrames;
    QMap<int, int> uniqueMemoryAddressesCounts;
    QMap<int, int> addressMap;
    bool modified;
    memory_t mem;
    //QQueue<QPair<QByteArray, int>> leaderboardFrames;
};


#endif // MEMORYREADER_H
