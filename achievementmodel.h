#ifndef ACHIEVEMENTMODEL_H
#define ACHIEVEMENTMODEL_H

#include <QAbstractListModel>
#include "rastructs.h"

class AchievementModel : public QAbstractListModel {
    Q_OBJECT

public:
    enum AchievementRoles {
        BadgeLockedUrlRole = Qt::UserRole + 1,
        BadgeNameRole,
        BadgeUrlRole,
        DescriptionRole,
        FlagsRole,
        IdRole,
        MemAddrRole,
        PointsRole,
        //RarityRole,
        //RarityHardcoreRole,
        TitleRole,
        TypeRole,
        //AuthorRole,
        TimeUnlockedRole,
        TimeUnlockedStringRole,
        UnlockedRole,
        AchievementLinkRole,
        PrimedRole,
        ValueRole,
        PercentRole,
        TargetRole
    };

    static AchievementModel* instance() {
        static AchievementModel instance;
        return &instance;
    }

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void setUnlockedState(const unsigned int& i, const bool& unlocked, const QDateTime& time);
    void primeAchievement(const unsigned int& id, const bool& p);
    void updateAchievementValue(const unsigned int& id, const int& value);
    void updateAchievementPercent(const unsigned int& id, const int& percent);
    void updateAchievementTarget(const unsigned int& id, const int& target);
    void clearAchievements();
    QList<AchievementInfo> getAchievements();
    void appendAchievement(AchievementInfo a);

signals:
    void unlockedChanged();

private:
    AchievementModel(QObject *parent = nullptr);
    AchievementModel(const AchievementModel&) = delete;
    AchievementModel& operator=(const AchievementModel&) = delete;

    QList<AchievementInfo> m_achievements;
};

#endif // ACHIEVEMENTMODEL_H
