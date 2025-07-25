#ifndef GAMEINFOMODEL_H
#define GAMEINFOMODEL_H

#include "rastructs.h"

class GameInfoModel : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString title READ title NOTIFY dataChanged)
    Q_PROPERTY(QString md5hash READ md5hash NOTIFY dataChanged)
    Q_PROPERTY(unsigned int id READ id NOTIFY dataChanged)
    Q_PROPERTY(QString image_icon READ image_icon NOTIFY dataChanged)
    Q_PROPERTY(QUrl image_icon_url READ image_icon_url NOTIFY dataChanged)
    Q_PROPERTY(QUrl game_link READ game_link NOTIFY dataChanged)
    Q_PROPERTY(QString console READ console NOTIFY dataChanged)
    Q_PROPERTY(QUrl console_icon READ console_icon NOTIFY dataChanged)
    Q_PROPERTY(unsigned int completion_count READ completion_count NOTIFY dataChanged)
    Q_PROPERTY(bool mastered READ mastered NOTIFY dataChanged)
    Q_PROPERTY(bool beaten READ beaten NOTIFY dataChanged)
    Q_PROPERTY(int point_total READ point_total NOTIFY dataChanged)
    Q_PROPERTY(unsigned int missable_count READ missable_count NOTIFY dataChanged)
    Q_PROPERTY(int point_count READ point_count NOTIFY dataChanged)
    Q_PROPERTY(int achievement_count READ achievement_count NOTIFY dataChanged)

public:
    static GameInfoModel* instance() {
        static GameInfoModel instance;
        return &instance;
    }

    void updateCompletionCount();
    void updatePointCount(unsigned int points);
    void updateMissableCount();

    QString title() const;
    QString md5hash() const;
    unsigned int id() const;
    QString image_icon() const;
    QUrl image_icon_url() const;
    QUrl game_link() const;
    QString console() const;
    QUrl console_icon() const;
    unsigned int completion_count() const;
    bool beaten() const;
    bool mastered() const;
    void clearGame();
    int point_total() const;
    unsigned int missable_count() const;
    int point_count() const;
    int achievement_count() const;
    QString rich_presence() const;

    void title(const QString& t);
    void md5hash(const QString& md5);
    void id(const unsigned int& i);
    void image_icon(const QString& ii);
    void image_icon_url(const QUrl& iu);
    void game_link(const QUrl& gl);
    void console(const QString& c);
    void console_icon(const QUrl& ci);
    void completion_count(const unsigned int& cc);
    void beaten(const bool& b);
    void mastered(const bool& m);
    void point_total(const int& pt);
    void missable_count(const unsigned int& mc);
    void point_count(const int& pc);
    void achievement_count(const int& ac);
    void rich_presence(const QString& rp);

signals:
    void dataChanged();
    void masteredGame();
    void beatenGame();

private:
    explicit GameInfoModel(QObject *parent = nullptr);
    GameInfoModel(const GameInfoModel&) = delete;
    GameInfoModel& operator=(const GameInfoModel&) = delete;

    GameInfo m_gameInfo;
};

#endif // GAMEINFOMODEL_H
