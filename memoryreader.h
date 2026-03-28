#ifndef MEMORYREADER_H
#define MEMORYREADER_H

#include <QObject>
#include <QList>
#include <QQueue>
#include "rc_internal.h"
#include "rastructs.h"

class MemoryReader : public QObject {
    Q_OBJECT

public:

    explicit MemoryReader(QObject *parent = nullptr);

    void initTriggers(const QList<AchievementInfo>& achievements, const QList<LeaderboardInfo>& leaderboards, const QString& richPresence,
                      const unsigned int& ramSize, const bool& customFirmware);
    QList<QPair<unsigned int, unsigned int>> getUniqueMemoryAddresses();
    bool processFrames(QByteArray& data, unsigned int& frames, bool& customFirmware);
    void resetRuntimeData();

signals:
    void achievementUnlocked(const unsigned int& id, const QDateTime& time);
    void leaderboardCompleted(const unsigned int& id, const QDateTime& time);
    void updateAchievementInfo(const unsigned int& id, const AchievementInfoType& infotype, const int& value);
    void updateRichPresence(const QString& status);

private:
    bool decrementAddressCounts(rc_memrefs_t &memrefs);
    void remapTriggerAddresses(bool modified);
    void mergeAddresses(const unsigned int blockSize);
    QList<QPair<unsigned int, unsigned int>> uniqueMemoryAddresses;
    QMap<unsigned int, rc_trigger_with_memrefs_t*> achievementTriggers;
    QMap<unsigned int, unsigned int> addressMap;
    QMap<unsigned int, int> addressCounts;
    //QMap<unsigned int, rc_lboard_t*> leaderboardTriggers;
    rc_richpresence_with_memrefs_t* mem_richpresence;
    int rpState;
};


#endif // MEMORYREADER_H
