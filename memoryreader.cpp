#include "memoryreader.h"
#include "rc_internal.h"
#include <QTimer>
//#include <QDebug>

MemoryReader::MemoryReader(QObject *parent) : QObject(parent) {
}

void MemoryReader::initTriggers(const QList<AchievementInfo>& achievements, const QList<LeaderboardInfo>& leaderboards, const QString& richPresence, const unsigned int& ramSize) {
    uniqueMemoryAddresses.clear();
    achievementTriggers.clear();
    leaderboardTriggers.clear();
    frameQueue.clear();
    rpState = 0;
    mem_richpresence = nullptr;
    QMap<unsigned int, unsigned int> uniqueAddresses;
    for (const AchievementInfo& achievement : achievements)
    {
        QByteArray data = achievement.mem_addr.toLocal8Bit();
        const char* mem_addr = data.constData();

        size_t trigger_size = rc_trigger_size(mem_addr);
        void* trigger_buffer = malloc(trigger_size);
        rc_trigger_t* trigger = rc_parse_trigger(trigger_buffer, mem_addr, nullptr, 0);
        rc_memrefs_t* memrefs = rc_trigger_get_memrefs(trigger);

        rc_trigger_with_memrefs_t* mem_trigger = (rc_trigger_with_memrefs_t*)malloc(sizeof(rc_trigger_with_memrefs_t));
        mem_trigger->trigger = *trigger;
        mem_trigger->memrefs = *memrefs;

        if (trigger->measured_target != 0)
        {
            emit updateAchievementInfo(achievement.id, Target, trigger->measured_target);

            if (achievement.unlocked)
            {
                emit updateAchievementInfo(achievement.id, Percent, 100);
                emit updateAchievementInfo(achievement.id, Value, trigger->measured_target);
                free(trigger_buffer);
                free(mem_trigger);
                continue;
            }
        }

        achievementTriggers[achievement.id] = mem_trigger;

        rc_memref_list_t* memref_list = &mem_trigger->memrefs.memrefs;
        for (; memref_list; memref_list = memref_list->next)
        {
            rc_memref_t* memref = memref_list->items;
            const rc_memref_t* memref_end = memref + memref_list->count;

            for (; memref < memref_end; ++memref)
            {
                memref->address = (memref->address > 0x1FFFF)
                                       ? (memref->address % ramSize) + 0xE00000
                                       : memref->address + 0xF50000;
                unsigned int requiredSize = memref->value.size + 1;
                unsigned int &entry = uniqueAddresses[memref->address];
                if (entry < requiredSize)
                    entry = requiredSize;
            }
        }
    }

    if(!richPresence.isEmpty())
    {
        //qDebug() << "RICH";
        QByteArray rc = richPresence.toUtf8();
        const char* script = rc.constData();
        int size = rc_richpresence_size(script);
        if(size > 0)
        {
            char* buffer;
            buffer = (char*)malloc(size + 4);
            mem_richpresence = (rc_richpresence_with_memrefs_t*)malloc(sizeof(rc_richpresence_with_memrefs_t));
            rc_richpresence_t* richpresence = rc_parse_richpresence(buffer, script, nullptr, 0);
            rc_memrefs_t* memrefs = rc_richpresence_get_memrefs(richpresence);
            mem_richpresence->memrefs = *memrefs;
            mem_richpresence->richpresence = *richpresence;
            rc_memref_list_t* memref_list = &mem_richpresence->memrefs.memrefs;
            for (; memref_list; memref_list = memref_list->next)
            {
                rc_memref_t* memref = memref_list->items;
                const rc_memref_t* memref_end = memref + memref_list->count;

                for (; memref < memref_end; ++memref)
                {
                    memref->address = (memref->address > 0x1FFFF)
                    ? (memref->address % ramSize) + 0xE00000
                    : memref->address + 0xF50000;
                    unsigned int requiredSize = memref->value.size + 1;
                    unsigned int &entry = uniqueAddresses[memref->address];
                    if (entry < requiredSize)
                        entry = requiredSize;
                }
            }
        }
    }

    /*if(!leaderboards.empty())
    {
        for(const LeaderboardInfo& leaderboard : leaderboards)
        {
            QByteArray data = leaderboard.mem_addr.toLocal8Bit();
            const char* mem_addr = data.constData();
            rc_lboard_t* lboard;
            size_t lboard_size = rc_lboard_size(mem_addr);
            void* lboard_buffer = malloc(lboard_size);
            lboard = rc_parse_lboard(lboard_buffer, mem_addr, NULL, 0);
            rc_memref_t* nextref = lboard->memrefs;
            leaderboardTriggers[leaderboard.id] = lboard;
            while(nextref != nullptr)
            {
                if(uniqueAddresses[nextref->address] < nextref->value.size + 1)
                    uniqueAddresses[nextref->address] = nextref->value.size + 1;
                nextref = nextref->next;
            }
        }
    }*/

    for(auto it = uniqueAddresses.begin(); it != uniqueAddresses.end(); ++it)
        uniqueMemoryAddresses.append(qMakePair(it.key(), it.value()));

    //qDebug() << uniqueAddresses;
    for (int i = 0; i < uniqueMemoryAddresses.size() - 1; i++)
    {
        auto& current = uniqueMemoryAddresses[i];
        auto& next = uniqueMemoryAddresses[i + 1];

        int gap = next.first - (current.first + current.second);

        if (gap < 0)
            gap = 0;

        int total_size = current.second + next.second + gap;
        if (total_size <= 255)
        {
            current.second = total_size;
            uniqueMemoryAddresses.remove(i + 1);
            i--;
        }
    }

    //qDebug() << uniqueMemoryAddresses;
    //qDebug() << uniqueAddresses.size() << uniqueMemoryAddresses.size();

    remapTriggerAddresses(false);
}

void MemoryReader::remapTriggerAddresses(bool modified)
{
    //qDebug() << uniqueMemoryAddresses << uniqueMemoryAddresses.size();
    QMutexLocker locker(&mutex);
    uniqueMemoryAddressesCounts.clear();
    QMap<unsigned int, unsigned int> temp;
    for (auto it = achievementTriggers.begin(); it != achievementTriggers.end(); ++it)
    {
        rc_memrefs_t* memrefs = &it.value()->memrefs;
        rc_memref_list_t* memref_list = &memrefs->memrefs;
        for (; memref_list; memref_list = memref_list->next)
        {
            rc_memref_t* memref = memref_list->items;
            const rc_memref_t* memref_end = memref + memref_list->count;

            for (; memref < memref_end; ++memref)
            {
                unsigned int addr = modified ? addressMap[memref->address] : memref->address;
                unsigned int memoryOffset = 0;

                for (auto blockIt = uniqueMemoryAddresses.cbegin(); blockIt != uniqueMemoryAddresses.cend(); ++blockIt)
                {
                    unsigned int blockStart = blockIt->first;
                    unsigned int blockSize = blockIt->second;
                    unsigned int blockEnd = blockStart + blockSize;

                    if (addr >= blockStart && addr < blockEnd)
                    {
                        unsigned int offsetInBlock = addr - blockStart;
                        unsigned int finalOffset = memoryOffset + offsetInBlock;

                        //qDebug() << "MA" << memref->address;
                        //qDebug() << "CA" << blockStart;
                        temp[finalOffset] = blockStart;
                        uniqueMemoryAddressesCounts[blockStart]++;
                        memref->address = finalOffset;
                        //qDebug() << "NA" << memref->address;

                        break;
                    }

                    memoryOffset += blockSize;
                }
            }
        }
    }

    if(mem_richpresence != nullptr)
    {
        rc_memrefs_t* memrefs = &mem_richpresence->memrefs;
        rc_memref_list_t* memref_list = &memrefs->memrefs;
        for (; memref_list; memref_list = memref_list->next)
        {
            rc_memref_t* memref = memref_list->items;
            const rc_memref_t* memref_end = memref + memref_list->count;

            for (; memref < memref_end; ++memref)
            {
                unsigned int addr = modified ? addressMap[memref->address] : memref->address;
                unsigned int memoryOffset = 0;

                for (auto blockIt = uniqueMemoryAddresses.cbegin(); blockIt != uniqueMemoryAddresses.cend(); ++blockIt)
                {
                    unsigned int blockStart = blockIt->first;
                    unsigned int blockSize = blockIt->second;
                    unsigned int blockEnd = blockStart + blockSize;

                    if (addr >= blockStart && addr < blockEnd)
                    {
                        unsigned int offsetInBlock = addr - blockStart;
                        unsigned int finalOffset = memoryOffset + offsetInBlock;

                        if(!temp.contains(finalOffset))
                            temp[finalOffset] = blockStart;
                        if(uniqueMemoryAddressesCounts.contains(blockStart))
                            uniqueMemoryAddressesCounts[blockStart]++;
                        memref->address = finalOffset;

                        break;
                    }

                    memoryOffset += blockSize;
                }
            }
        }
    }

    /*for(auto it = leaderboardTriggers.begin(); it != leaderboardTriggers.end(); ++it)
    {
        rc_memref_t* nextref = it.value()->memrefs;
        while(nextref != nullptr)
        {
            int memoryOffset = 0;
            for(const auto& pair : uniqueMemoryAddresses)
            {
                if(pair.first == nextref->address)
                {
                    //qDebug() << "Unique Address: " << pair.first;
                    //qDebug() << "Trigger Address:" << nextref->address;
                    nextref->address = memoryOffset;
                    //qDebug() << "Memory Offset: " << memoryOffset;
                    //qDebug() << "New Trigger Address: " << nextref->address;
                    break;
                }
                memoryOffset += pair.second;
            }
            nextref = nextref->next;
        }
    }*/

    //qDebug() << "Setup Finished";
    addressMap = temp;
    if(!modified)
        emit finishedMemorySetup();
    //qDebug() << addressMap;
}

void MemoryReader::addFrameToQueues(const QByteArray& data, const unsigned int& frames)
{
    {
        QMutexLocker locker(&mutex);
        frameQueue.enqueue(qMakePair(data, frames));
    }
    QTimer::singleShot(0, this, [this] { processFrames(); });
}

void MemoryReader::clearQueue()
{
    frameQueue.clear();
}

QList<QPair<unsigned int, unsigned int>> MemoryReader::getUniqueMemoryAddresses()
{
    QMutexLocker locker(&mutex);
    return uniqueMemoryAddresses;
}

// peekb and peek are taken from rcheevos/mock_memory.h
static uint32_t peekb(uint32_t address, memory_t* memory) {
    return address < memory->size ? memory->ram[address] : 0;
}

static uint32_t peek(uint32_t address, uint32_t num_bytes, void* ud) {
    memory_t* memory = (memory_t*)ud;
    //qDebug() << "A, N" << address << num_bytes;
    //qDebug() << "R, S" << memory->ram << memory->size;

    switch (num_bytes) {
    case 1: return peekb(address, memory);

    case 2: return peekb(address, memory) |
               peekb(address + 1, memory) << 8;

    case 4: return peekb(address, memory) |
               peekb(address + 1, memory) << 8 |
               peekb(address + 2, memory) << 16 |
               peekb(address + 3, memory) << 24;
    }

    return 0;
}

void MemoryReader::decrementAddressCounts(rc_memrefs_t& memrefs)
{
    QMutexLocker locker(&mutex);
    int type = 0;
    rc_memref_list_t* memref_list = &memrefs.memrefs;
    for (; memref_list; memref_list = memref_list->next)
    {
        rc_memref_t* memref = memref_list->items;
        const rc_memref_t* memref_end = memref + memref_list->count;

        for (; memref < memref_end; ++memref)
        {
            const unsigned int& mappedAddress = addressMap[memref->address];
            unsigned int& count = uniqueMemoryAddressesCounts[mappedAddress];

            auto it = std::find_if(uniqueMemoryAddresses.begin(), uniqueMemoryAddresses.end(),
                                   [mappedAddress](const QPair<unsigned int, unsigned int>& pair) {
                                       return pair.first == mappedAddress;
                                   });

            if(it == uniqueMemoryAddresses.end())
                continue;
            if(--count < 1)
            {
                uniqueMemoryAddresses.erase(it);
                type = 1;
            }
            else if(mappedAddress + memref->address == it->first + it->second)
            {
                it->second -= memref->address;
                type = 2;
            }
        }
    }
    switch(type)
    {
    case 1:
        remapTriggerAddresses(true);
    case 2:
        emit modifiedAddresses(uniqueMemoryAddresses);
    default:
        break;
    }
}

void MemoryReader::processFrames()
{
    QPair<QByteArray, unsigned> frame;

    {
        QMutexLocker locker(&mutex);
        if (frameQueue.isEmpty()) return;
        frame = frameQueue.dequeue();
    }

    memory_t mem;
    mem.ram = reinterpret_cast<uint8_t*>(const_cast<char*>(frame.first.data()));
    mem.size = frame.first.size();

    if(mem_richpresence != nullptr)
    {
        char output[256];
        int new_state = rc_evaluate_richpresence(&mem_richpresence->richpresence, output, sizeof(output), peek, &mem, nullptr);
        int old_state = rpState.loadAcquire();
        if(new_state != old_state)
        {
            rpState.storeRelease(new_state);
            emit updateRichPresence(QByteArray(output));
        }
    }

    while(frame.second > 0)
    {
        QList<unsigned int> ids;

        {
            QMutexLocker locker(&mutex);
            for(auto it = achievementTriggers.begin(); it != achievementTriggers.end(); ++it)
            {
                rc_trigger_t* trigger = &it.value()->trigger;
                if (!trigger) continue;

                int old_state = trigger->state;
                uint32_t old_measured_value = trigger->measured_value;

                trigger->state = RC_TRIGGER_STATE_ACTIVE;
                int new_state = rc_evaluate_trigger(trigger, peek, &mem, nullptr);

                if (trigger->measured_value != old_measured_value &&
                    old_measured_value != RC_MEASURED_UNKNOWN &&
                    trigger->measured_target != 0 &&
                    trigger->measured_value <= trigger->measured_target &&
                    new_state != RC_TRIGGER_STATE_TRIGGERED &&
                    new_state != RC_TRIGGER_STATE_INACTIVE &&
                    new_state != RC_TRIGGER_STATE_WAITING)
                {
                    const int32_t new_percent = (int32_t)(((quint64)trigger->measured_value * 100) / trigger->measured_target);
                    emit updateAchievementInfo(it.key(), Percent, new_percent);
                    emit updateAchievementInfo(it.key(), Value, trigger->measured_value);
                }

                if(new_state == old_state) continue;

                if (old_state == RC_TRIGGER_STATE_PRIMED)
                    emit updateAchievementInfo(it.key(), Primed, false);

                switch (new_state)
                {
                case RC_TRIGGER_STATE_TRIGGERED:
                    ids.append(it.key());
                    emit updateAchievementInfo(it.key(), Value, trigger->measured_value);
                    emit updateAchievementInfo(it.key(), Percent, 100);
                    emit achievementUnlocked(it.key(), QDateTime::currentDateTime());
                    decrementAddressCounts(it.value()->memrefs);
                    break;

                case RC_TRIGGER_STATE_PRIMED:
                    emit updateAchievementInfo(it.key(), Primed, true);
                    break;

                default:
                    break;
                }
            }
        }

        {
            QMutexLocker locker(&mutex);
            for(const auto& id : ids)
            {
                free(achievementTriggers[id]);
                achievementTriggers.remove(id);
            }
        }

        frame.second--;
    }

    {
        QMutexLocker locker(&mutex);
        if(!frameQueue.isEmpty())
            QTimer::singleShot(0, this, [this] { processFrames(); });
    }
}

/*void MemoryReader::checkLeaderboards()
{
    emit leaderboardsChecked();
}*/
