#include "memoryreader.h"
#include "rc_internal.h"
//#include <QDebug>

MemoryReader::MemoryReader(QObject *parent) : QObject(parent) {
}

void MemoryReader::initTriggers(const QList<AchievementInfo> achievements, const QList<LeaderboardInfo> leaderboards, unsigned int ramSize) {
    uniqueMemoryAddresses.clear();
    achievementTriggers.clear();
    leaderboardTriggers.clear();
    achievementFrames.clear();
    modified = false;
    QMap<int, int> uniqueAddresses;
    for(const AchievementInfo& achievement : achievements)
    {

        QByteArray data = achievement.mem_addr.toLocal8Bit();
        const char* mem_addr = data.constData();
        rc_trigger_t* trigger;
        size_t trigger_size = rc_trigger_size(mem_addr);
        void* trigger_buffer = malloc(trigger_size);
        trigger = rc_parse_trigger(trigger_buffer, mem_addr, NULL, 0);
        if(trigger->measured_target != 0)
            emit updateAchievementInfo(achievement.id, Target, trigger->measured_target);
        if(!achievement.unlocked)
        {
            achievementTriggers[achievement.id] = trigger;
            rc_memref_t* nextref = trigger->memrefs;
            while(nextref != nullptr)
            {
                if(nextref->address > 0x1FFFF) //sram check
                    nextref->address = (nextref->address % ramSize) + 0xE00000;
                else
                    nextref->address += 0xF50000;
                //qDebug() << nextref->address;
                if(uniqueAddresses[nextref->address] < nextref->value.size + 1)
                    uniqueAddresses[nextref->address] = nextref->value.size + 1;
                uniqueMemoryAddressesCounts[nextref->address]++;
                nextref = nextref->next;
            }

        }
        else
        {
            if(trigger->measured_target != 0)
            {
                emit updateAchievementInfo(achievement.id, Percent, 100);
                emit updateAchievementInfo(achievement.id, Value, trigger->measured_target);
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

    //qDebug() << uniqueMemoryAddressesCounts;

    remapTriggerAddresses();
}

void MemoryReader::remapTriggerAddresses()
{
    //qDebug() << uniqueMemoryAddresses << uniqueMemoryAddresses.size();
    QMap<int, int> temp;
    for(auto it = achievementTriggers.begin(); it != achievementTriggers.end(); ++it)
    {
        rc_memref_t* nextref = it.value()->memrefs;
        while(nextref != nullptr)
        {
            int memoryOffset = 0;
            for(auto it = uniqueMemoryAddresses.cbegin(); it != uniqueMemoryAddresses.cend(); ++it)
            {
                int addr = modified ? addressMap[nextref->address] : nextref->address;
                if(it->first == addr)
                {
                    temp[memoryOffset] = it->first;
                    nextref->address = memoryOffset;
                    break;
                }
                memoryOffset += it->second;
            }
            nextref = nextref->next;
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
    modified = false;
    //qDebug() << addressMap;
}

void MemoryReader::addFrameToQueues(QByteArray data, int frames)
{
    achievementFrames.enqueue(qMakePair(data, frames));
    //LeaderBoardFramesToCheck.enqueue(qMakePair(data, frames))
}

int MemoryReader::achievementQueueSize()
{
    return achievementFrames.size();
}

QList<QPair<int, int>> MemoryReader::getUniqueMemoryAddresses()
{
    return uniqueMemoryAddresses;
}

static uint32_t peek(uint32_t address, uint32_t num_bytes, void* ud) {
    uint8_t* memory = (uint8_t*)ud;

    switch (num_bytes) {
    case 1: return memory[address];

    case 2: return memory[address] |
               memory[address + 1] << 8;

    case 4: return memory[address] |
               memory[address + 1] << 8 |
               memory[address + 2] << 16 |
               memory[address + 3] << 24;
    }

    return 0;
}

void MemoryReader::decrementAddressCounts(rc_memref_t* nextref)
{
    //qDebug() << "Decrementing Address Counts";
    while(nextref != nullptr)
    {
        //qDebug() << "Address:" << nextref->address;
        //qDebug() << "Mapped:" << addressMap[nextref->address];
        //qDebug() << "Address Count:" << uniqueMemoryAddressesCounts[addressMap[nextref->address]];
        if(--uniqueMemoryAddressesCounts[addressMap[nextref->address]] < 1)
        {
            uniqueMemoryAddressesCounts.remove(addressMap[nextref->address]);
            for(int i = 0; i < uniqueMemoryAddresses.size(); i++)
            {
                //qDebug() << "Unique:" << uniqueMemoryAddresses[i].first;
                if(addressMap[nextref->address] == uniqueMemoryAddresses[i].first)
                {
                    modified = true;
                    uniqueMemoryAddresses.removeAt(i);
                    addressMap.remove(nextref->address);
                    break;
                }
            }
        }
        nextref = nextref->next;
    }
    //qDebug() << uniqueMemoryAddressesCounts;
    //qDebug() << "Modified:" << modified;
    if(modified)
        emit modifiedAddresses();
}

void MemoryReader::checkAchievements()
{
    //qDebug() << achievementFrames;
    while(achievementFrames.size() > 0)
    {
        for(int frame = 0; frame < achievementFrames.first().second; frame++)
        {
            QList<int> ids;
            for(auto it = achievementTriggers.begin(); it != achievementTriggers.end(); ++it)
            {
                rc_trigger_t* trigger = it.value();
                int old_state, new_state;
                uint32_t old_measured_value;

                if (!trigger)
                    continue;

                old_measured_value = trigger->measured_value;
                old_state = trigger->state;
                rc_evaluate_trigger(trigger, peek, achievementFrames.first().first.data(), nullptr);
                new_state = trigger->state;

                if (trigger->measured_value != old_measured_value &&
                    old_measured_value != RC_MEASURED_UNKNOWN &&
                    trigger->measured_target != 0 &&
                    trigger->measured_value <= trigger->measured_target &&
                    new_state != RC_TRIGGER_STATE_TRIGGERED &&
                    new_state != RC_TRIGGER_STATE_INACTIVE &&
                    new_state != RC_TRIGGER_STATE_WAITING)
                {
                    const int32_t new_percent = (int32_t)(((unsigned long long)trigger->measured_value * 100) / trigger->measured_target);
                    emit updateAchievementInfo(it.key(), Percent, new_percent);
                    emit updateAchievementInfo(it.key(), Value, trigger->measured_value);
                }

                /* if the state hasn't changed, there won't be any events raised */
                if(new_state == old_state)
                    continue;

                /* raise an UNPRIMED event when changing from PRIMED to anything else */
                if (old_state == RC_TRIGGER_STATE_PRIMED)
                    emit updateAchievementInfo(it.key(), Primed, false);

                /* raise events for each of the possible new states */
                switch (new_state)
                {
                case RC_TRIGGER_STATE_TRIGGERED:
                    //qDebug() << "Achievement Unlocked: " << it.key();
                    ids.append(it.key());
                    emit updateAchievementInfo(it.key(), Value, trigger->measured_value);
                    emit updateAchievementInfo(it.key(), Percent, 100);
                    emit achievementUnlocked(it.key(), QDateTime::currentDateTime());
                    decrementAddressCounts(trigger->memrefs);
                    break;

                case RC_TRIGGER_STATE_PRIMED:
                    emit updateAchievementInfo(it.key(), Primed, true);
                    break;

                default:
                    break;
                }
            }
            for(const auto& id : ids)
                achievementTriggers.remove(id);
            if(modified)
                remapTriggerAddresses();
        }
        achievementFrames.dequeue();
    }
}

void MemoryReader::checkLeaderboards()
{
    emit leaderboardsChecked();
}
