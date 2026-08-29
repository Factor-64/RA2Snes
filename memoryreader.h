#ifndef MEMORYREADER_H
#define MEMORYREADER_H

#include <QObject>
#include <QList>
#include <QQueue>
#include "rc_internal.h"
#include "raclient.h"
#include "rastructs.h"

class MemoryReader : public QObject {
    Q_OBJECT

public:
    explicit MemoryReader(QObject *parent = nullptr);
    void initTriggers(const QList<AchievementInfo>& achievements, const QString& richPresence, const unsigned int& ramSize, const bool customFirmware);
    QList<QPair<unsigned int, unsigned int>> getUniqueMemoryAddresses();
    bool processFrame(QByteArray& data, bool& customFirmware);
    void resetRuntimeData();

signals:
    void updateRichPresence(const QString& status);

private:
    bool decrementAddressCounts(rc_memrefs_t &memrefs);
    void remapTriggerAddresses(bool modified);
    void mergeAddresses(const unsigned int blockSize);
    QList<QPair<unsigned int, unsigned int>> uniqueMemoryAddresses;
    QMap<unsigned int, rc_trigger_with_memrefs_t*> achievementTriggers;
    QMap<unsigned int, unsigned int> addressMap;
    QMap<unsigned int, int> addressCounts;
    RAClient* raclient;
    rc_richpresence_with_memrefs_t* mem_richpresence;
    int rpState;
};


#endif // MEMORYREADER_H
