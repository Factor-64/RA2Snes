#ifndef RASTRUCTS_H
#define RASTRUCTS_H

#include <QUrl>
#include <QDateTime>

enum AchievementInfoType {
    Primed,
    Value,
    Percent,
    Target
};

// memory_t taken from rcheevos/mock_memory.h
typedef struct {
    uint8_t* ram;
    uint32_t size;
}
memory_t;

struct AchievementInfo {
    QUrl badge_locked_url;
    QString badge_name = "";
    QUrl badge_url;
    //QDateTime created;
    QString description = "";
    unsigned int flags = 0;
    unsigned int id = 0;
    QString mem_addr = "";
    //QDateTime modified;
    unsigned int points = 0;
    //unsigned int rarity;
    //unsigned int rarity_hardcore;
    QString title = "";
    QString type = "";
    //QString author;
    QString time_unlocked_string = "";
    QDateTime time_unlocked;
    bool unlocked = false;
    QUrl achievement_link;
    bool primed = false;
    int value = 0;
    int percent = 0;
    int target = 0;
};

struct LeaderboardInfo {
    QString title;
    QString description;
    QString format;
    unsigned int id;
    int lower_is_better;
    QString mem_addr;
    unsigned int score;
    unsigned int seconds_since_completion;
    QUrl leaderboard_link;
    unsigned int placement;
};

struct UserInfo {
    QString username;
    QString token;
    int softcore_score;
    int hardcore_score;
    QUrl pfp;
    bool hardcore;
    QUrl link;
    int width;
    int height;
    bool savestates;
    bool cheats;
    bool patched;
    bool autohardcore;
    bool compact;
    bool ingamehooks;
    bool banner;
    bool icons;
    bool iconspopup;
    QString theme;
};

struct GameInfo {
    QString title = "";
    QString md5hash = "";
    unsigned int id = 0;
    QString image_icon = "";
    QUrl image_icon_url;
    QUrl game_link;
    QString console = "";
    QUrl console_icon;
    unsigned int completion_count = 0;
    bool beaten = false;
    bool mastered = false;
    int point_total = 0;
    unsigned int missable_count = 0;
    int point_count = 0;
    int achievement_count = 0;
    QString rich_presence = "";
};

#endif // RASTRUCTS_H
