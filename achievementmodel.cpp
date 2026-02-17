#include "achievementmodel.h"

AchievementModel::AchievementModel(QObject *parent)
    : QAbstractListModel(parent) {}

int AchievementModel::rowCount(const QModelIndex &parent) const {
    Q_UNUSED(parent);
    return m_achievements.count();
}

QVariant AchievementModel::data(const QModelIndex &index, int role) const {
    if (index.row() < 0 || index.row() >= m_achievements.count())
        return QVariant();

    const AchievementInfo &achievement = m_achievements[index.row()];

    switch (role) {
    case BadgeLockedUrlRole:
        return achievement.badge_locked_url;
    case BadgeNameRole:
        return achievement.badge_name;
    case BadgeUrlRole:
        return achievement.badge_url;
    case DescriptionRole:
        return achievement.description;
    case FlagsRole:
        return achievement.flags;
    case IdRole:
        return achievement.id;
    case MemAddrRole:
        return achievement.mem_addr;
    case PointsRole:
        return achievement.points;
    //case RarityRole:
    //    return achievement.rarity;
    //case RarityHardcoreRole:
    //    return achievement.rarity_hardcore;
    case TitleRole:
        return achievement.title;
    case TypeRole:
        return achievement.type;
    //case AuthorRole:
    //    return achievement.author;
    case TimeUnlockedRole:
        return achievement.time_unlocked;
    case TimeUnlockedStringRole:
        return achievement.time_unlocked_string;
    case UnlockedRole:
        return achievement.unlocked;
    case AchievementLinkRole:
        return achievement.achievement_link;
    case PrimedRole:
        return achievement.primed;
    case ValueRole:
        return achievement.value;
    case PercentRole:
        return achievement.percent;
    case TargetRole:
        return achievement.target;
    default:
        return QVariant();
    }
}

QVariantMap AchievementModel::get(int row) const {
    QVariantMap map;
    if (row < 0 || row >= m_achievements.size())
        return map;

    const auto &a = m_achievements.at(row);

    map["badgeLockedUrl"] = a.badge_locked_url;
    map["badgeName"] = a.badge_name;
    map["badgeUrl"] = a.badge_url;
    map["description"] = a.description;
    map["flags"] = a.flags;
    map["id"] = a.id;
    map["memAddr"] = a.mem_addr;
    map["points"] = a.points;
    map["title"] = a.title;
    map["type"] = a.type;
    map["timeUnlocked"] = a.time_unlocked;
    map["timeUnlockedString"] = a.time_unlocked_string;
    map["unlocked"] = a.unlocked;
    map["achievementLink"] = a.achievement_link;
    map["primed"] = a.primed;
    map["value"] = a.value;
    map["percent"] = a.percent;
    map["target"] = a.target;

    return map;
}

QHash<int, QByteArray> AchievementModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[BadgeLockedUrlRole] = "badgeLockedUrl";
    roles[BadgeNameRole] = "badgeName";
    roles[BadgeUrlRole] = "badgeUrl";
    roles[DescriptionRole] = "description";
    roles[FlagsRole] = "flags";
    roles[IdRole] = "id";
    roles[MemAddrRole] = "memAddr";
    roles[PointsRole] = "points";
    //roles[RarityRole] = "rarity";
    //roles[RarityHardcoreRole] = "rarityHardcore";
    roles[TitleRole] = "title";
    roles[TypeRole] = "type";
    //roles[AuthorRole] = "author";
    roles[TimeUnlockedRole] = "timeUnlocked";
    roles[TimeUnlockedStringRole] = "timeUnlockedString";
    roles[UnlockedRole] = "unlocked";
    roles[AchievementLinkRole] = "achievementLink";
    roles[PrimedRole] = "primed";
    roles[ValueRole] = "value";
    roles[PercentRole] = "percent";
    roles[TargetRole] = "target";
    return roles;
}

void AchievementModel::setUnlockedState(const unsigned int& i, const bool& unlocked, const QDateTime& time, const bool& e) {
    m_achievements[i].unlocked = unlocked;
    m_achievements[i].time_unlocked = time;
    m_achievements[i].time_unlocked_string = time.toString("MMMM d yyyy, h:mmap");
    QModelIndex index = createIndex(i, 0);
    emit dataChanged(index, index, {UnlockedRole, TimeUnlockedRole, TimeUnlockedStringRole});
    if(e)
        emit unlockedChanged(i);
}

void AchievementModel::primeAchievement(const unsigned int& id, const bool& p) {
    for (int i = 0; i < m_achievements.size(); ++i) {
        if (m_achievements[i].id == id) {
            if (m_achievements[i].unlocked) return;
            m_achievements[i].primed = p;
            QModelIndex index = createIndex(i, 0);
            emit dataChanged(index, index, {PrimedRole});
            emit primedChanged(m_achievements[i].badge_url, p);
            break;
        }
    }
}

void AchievementModel::updateAchievementValue(const unsigned int& id, const int& value) {
    for (int i = 0; i < m_achievements.size(); ++i) {
        if (m_achievements[i].id == id) {
            if (m_achievements[i].unlocked) return;
            m_achievements[i].value = value;
            QModelIndex index = createIndex(i, 0);
            emit dataChanged(index, index, {ValueRole});
            if(!m_achievements[i].unlocked && m_achievements[i].target)
                emit valueChanged(m_achievements[i].badge_url, value, m_achievements[i].target);
            break;
        }
    }
}

void AchievementModel::updateAchievementPercent(const unsigned int& id, const int& percent) {
    for (int i = 0; i < m_achievements.size(); ++i) {
        if (m_achievements[i].id == id) {
            m_achievements[i].percent = percent;
            QModelIndex index = createIndex(i, 0);
            emit dataChanged(index, index, {PercentRole});
            break;
        }
    }
}

void AchievementModel::updateAchievementTarget(const unsigned int& id, const int& target) {
    for (int i = 0; i < m_achievements.size(); ++i) {
        if (m_achievements[i].id == id) {
            m_achievements[i].target = target;
            QModelIndex index = createIndex(i, 0);
            emit dataChanged(index, index, {TargetRole});
            break;
        }
    }
}

void AchievementModel::clearAchievements() {
    beginResetModel();
    m_achievements.clear();
    endResetModel();
}

QList<AchievementInfo> AchievementModel::getAchievements() {
    return m_achievements;
}

void AchievementModel::appendAchievement(AchievementInfo a) {
    beginInsertRows(QModelIndex(), m_achievements.size(), m_achievements.size());
    m_achievements.append(a);
    endInsertRows();
}
