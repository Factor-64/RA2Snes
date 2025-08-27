#ifndef USERINFOMODEL_H
#define USERINFOMODEL_H

#include "rastructs.h"

class UserInfoModel : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString username READ username NOTIFY dataChanged)
    Q_PROPERTY(int softcore_score READ softcore_score NOTIFY dataChanged)
    Q_PROPERTY(int hardcore_score READ hardcore_score NOTIFY dataChanged)
    Q_PROPERTY(QUrl pfp READ pfp NOTIFY dataChanged)
    Q_PROPERTY(bool hardcore READ hardcore NOTIFY dataChanged)
    Q_PROPERTY(QUrl link READ link NOTIFY dataChanged)
    Q_PROPERTY(int width READ width CONSTANT)
    Q_PROPERTY(int height READ height CONSTANT)
    Q_PROPERTY(bool autohardcore READ autohardcore NOTIFY dataChanged)
    Q_PROPERTY(bool compact READ compact CONSTANT)
    Q_PROPERTY(bool banner READ banner CONSTANT)

public:
    static UserInfoModel* instance() {
        static UserInfoModel instance;
        return &instance;
    }

    QString username() const;
    QString token() const;
    int softcore_score() const;
    int hardcore_score() const;
    QUrl pfp() const;
    bool hardcore() const;
    QUrl link() const;
    int width() const;
    int height() const;
    bool savestates() const;
    bool cheats() const;
    bool patched() const;
    void clearUser();
    bool autohardcore() const;
    bool compact() const;
    bool ingamehooks() const;
    bool banner() const;

    void username(const QString& u);
    void token(const QString& t);
    void softcore_score(const int& s);
    void hardcore_score(const int& hs);
    void pfp(const QUrl& p);
    void hardcore(const bool& h);
    void link(const QUrl& l);
    void savestates(const bool& s);
    void cheats(const bool& c);
    void patched(const bool& p);
    void autohardcore(const bool& a);
    void width(const int& w);
    void height(const int& h);
    void compact(const bool& c);
    void ingamehooks(const bool& n);
    void banner(const bool& n);

signals:
    void dataChanged();

private:
    explicit UserInfoModel(QObject *parent = nullptr);
    UserInfoModel(const UserInfoModel&) = delete;
    UserInfoModel& operator=(const UserInfoModel&) = delete;

    UserInfo m_userInfo;
};

#endif // USERINFOMODEL_H
