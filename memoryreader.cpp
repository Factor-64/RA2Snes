#include "memoryreader.h"
#include "rc_internal.h"
#include "rc_runtime_types.h"
#include <QElapsedTimer>
//#include <QDebug>

MemoryReader::MemoryReader(QObject *parent) : QObject(parent) {
    mem_richpresence = nullptr;
    rpState = 0;
    uniqueMemoryAddresses.clear();
    uniqueMemoryAddressesCounts.clear();
    addressMap.clear();
    achievementTriggers.clear();
}

void MemoryReader::initTriggers(const QList<AchievementInfo>& achievements, const QList<LeaderboardInfo>& leaderboards, const QString& richPresence, const unsigned int& ramSize, const bool& customFirmware)
{
    uniqueMemoryAddresses.clear();
    for (auto it = achievementTriggers.begin(); it != achievementTriggers.end(); ++it) {
        free(it.value());
    }
    if(mem_richpresence != nullptr)
        free(mem_richpresence);

    achievementTriggers.clear();
    //leaderboardTriggers.clear();
    rpState = 0;
    //currentRead = 0;
    mem_richpresence = nullptr;

    QMap<unsigned int, unsigned int> uniqueAddresses;
    for (const AchievementInfo& achievement : achievements)
    {
        if(achievement.id == 101000001)
            continue;
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

    //unsigned int total = 0;
    for(auto it = uniqueAddresses.begin(); it != uniqueAddresses.end(); ++it)
    {
        uniqueMemoryAddresses.append(qMakePair(it.key(), it.value()));
        //total += it.value();
    }
    //qDebug() << uniqueMemoryAddresses << uniqueMemoryAddresses.size();
    //qDebug() << uniqueMemoryAddresses << uniqueMemoryAddresses.size() << total;
    //qDebug() << uniqueMemoryAddresses.size() << total;

    if(customFirmware)
    {
        unsigned int amount = 4;
        while(uniqueMemoryAddresses.size() > 320)
        {
            mergeAddresses(amount);
            amount += 4;
        }
        //mergeAddresses(64);
    }
    else
    {
        mergeAddresses(255);
    }

    /*total = 0;
    for (int i = 0; i < uniqueMemoryAddresses.size(); ++i)
    {
        total += uniqueMemoryAddresses[i].second;
    }
    qDebug() << uniqueMemoryAddresses << uniqueMemoryAddresses.size() << total;*/
    //qDebug() << uniqueMemoryAddresses << uniqueMemoryAddresses.size();
    //qDebug() << uniqueMemoryAddresses.size() << total;
    remapTriggerAddresses(false);
}

void MemoryReader::mergeAddresses(unsigned int blockSize)
{
    for (int i = 0; i + 1 < uniqueMemoryAddresses.size(); )
    {
        auto &current = uniqueMemoryAddresses[i];
        auto &next    = uniqueMemoryAddresses[i + 1];

        unsigned int currentEnd = current.first + current.second;
        unsigned int gap        = (next.first > currentEnd) ? (next.first - currentEnd) : 0;

        unsigned int totalSize  = current.second + gap + next.second;

        if (totalSize <= blockSize)
        {
            current.second = totalSize;
            uniqueMemoryAddresses.removeAt(i + 1);
        }
        else
        {
            ++i;
        }
    }
}

void MemoryReader::remapTriggerAddresses(bool modified)
{
    //qDebug() << uniqueMemoryAddresses << uniqueMemoryAddresses.size();
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

                        temp[finalOffset] = blockStart;
                        uniqueMemoryAddressesCounts[blockStart]++;
                        memref->address = finalOffset;

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

    //qDebug() << "Setup Finished";
    addressMap = temp;
    if(!modified)
        emit finishedMemorySetup();
}

QList<QPair<unsigned int, unsigned int>> MemoryReader::getUniqueMemoryAddresses()
{
    return uniqueMemoryAddresses;
}

// peekb and peek are taken from rcheevos/mock_memory.h
static uint32_t peekb(uint32_t address, memory_t* memory) {
    return address < memory->size ? memory->ram[address] : 0;
}

static uint32_t peek(uint32_t address, uint32_t num_bytes, void* ud) {
    memory_t* memory = (memory_t*)ud;

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
                auto last = uniqueMemoryAddresses.end();
                --last;
                if(it != last)
                    type = 1;
                else
                    type = 2;
                uniqueMemoryAddresses.erase(it);
            }
            else if(mappedAddress + memref->address == it->first + it->second)
            {
                it->second -= memref->address;
                type = 2;
            }
        }
    }
    //oldMemory.clear();
    switch(type)
    {
    case 1:
        remapTriggerAddresses(true);
    case 2:
        emit modifiedAddresses();
    default:
        break;
    }
}

void MemoryReader::processFrames(QByteArray& data, unsigned int& frames)
{
    memory_t mem;
    mem.ram = reinterpret_cast<uint8_t*>(const_cast<char*>(data.constData()));
    mem.size = data.size();

    if(mem_richpresence != nullptr)
    {
        char output[256];
        int new_state = rc_evaluate_richpresence(&mem_richpresence->richpresence, output, sizeof(output), peek, &mem, nullptr);
        if(new_state != rpState)
        {
            rpState = new_state;
            emit updateRichPresence(QByteArray(output));
        }
    }

    while (frames > 0)
    {
        for (auto it = achievementTriggers.begin(); it != achievementTriggers.end(); )
        {
            auto* entry = it.value();
            if (!entry) { it = achievementTriggers.erase(it); continue; }

            rc_trigger_t* trigger = &entry->trigger;

            int old_state = trigger->state;
            uint32_t old_measured_value = trigger->measured_value;
            int new_state = rc_evaluate_trigger(trigger, peek, &mem, nullptr);

            if (trigger->measured_value != old_measured_value &&
                old_measured_value != RC_MEASURED_UNKNOWN &&
                trigger->measured_target != 0 &&
                trigger->measured_value <= trigger->measured_target &&
                new_state != RC_TRIGGER_STATE_TRIGGERED &&
                new_state != RC_TRIGGER_STATE_INACTIVE &&
                new_state != RC_TRIGGER_STATE_WAITING)
            {
                const int32_t new_percent =
                    (int32_t)(((quint64)trigger->measured_value * 100) / trigger->measured_target);
                emit updateAchievementInfo(it.key(), Percent, new_percent);
                emit updateAchievementInfo(it.key(), Value, trigger->measured_value);
            }

            if (new_state == old_state) {
                ++it;
                continue;
            }

            if (old_state == RC_TRIGGER_STATE_PRIMED)
                emit updateAchievementInfo(it.key(), Primed, false);

            switch (new_state)
            {
            case RC_TRIGGER_STATE_TRIGGERED: {
                emit updateAchievementInfo(it.key(), Value, trigger->measured_value);
                emit updateAchievementInfo(it.key(), Percent, 100);
                emit achievementUnlocked(it.key(), QDateTime::currentDateTime());

                decrementAddressCounts(entry->memrefs);
                free(entry);
                it = achievementTriggers.erase(it);
                continue;
            }
            case RC_TRIGGER_STATE_PRIMED:
                emit updateAchievementInfo(it.key(), Primed, true);
                break;

            default:
                break;
            }

            ++it;
        }

        --frames;
    }
}

void MemoryReader::resetRuntimeData()
{
    for (auto it = achievementTriggers.begin(); it != achievementTriggers.end(); ++it)
    {
        auto* entry = it.value();
        rc_trigger_t* trigger = &entry->trigger;
        rc_reset_trigger(trigger);
    }

    rc_reset_richpresence(&mem_richpresence->richpresence);
}
