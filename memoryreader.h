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

    void initTriggers(const QList<AchievementInfo>& achievements, const QList<LeaderboardInfo>& leaderboards, const QString& richPresence, const unsigned int& ramSize);
    void remapTriggerAddresses(bool modified);
    QList<QPair<unsigned int, unsigned int>> getUniqueMemoryAddresses();
    void processFrames(const QByteArray& data, unsigned int& frames);

signals:
    void finishedMemorySetup();
    void achievementUnlocked(const unsigned int& id, const QDateTime& time);
    void leaderboardCompleted(const unsigned int& id, const QDateTime& time);
    void updateAchievementInfo(const unsigned int& id, const AchievementInfoType& infotype, const int& value);
    void modifiedAddresses();
    void updateRichPresence(const QString& status);

private:
    void decrementAddressCounts(rc_memrefs_t& memrefs);
    QList<QPair<unsigned int, unsigned int>> uniqueMemoryAddresses;
    QMap<unsigned int, rc_trigger_with_memrefs_t*> achievementTriggers;
    //QMap<unsigned int, rc_lboard_t*> leaderboardTriggers;
    QMap<unsigned int, unsigned int> uniqueMemoryAddressesCounts;
    QMap<unsigned int, unsigned int> addressMap;
    rc_richpresence_with_memrefs_t* mem_richpresence;
    int rpState;
};


#endif // MEMORYREADER_H
