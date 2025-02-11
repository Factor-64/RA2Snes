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
        AuthorRole,
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

    void setUnlockedState(unsigned int id, bool unlocked, QDateTime time);
    void primeAchievement(unsigned int id, bool p);
    void updateAchievementValue(unsigned int id, int value);
    void updateAchievementPercent(unsigned int id, int percent);
    void updateAchievementTarget(unsigned int id, int target);
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
