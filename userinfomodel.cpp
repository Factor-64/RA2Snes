#include "userinfomodel.h"

UserInfoModel::UserInfoModel(QObject *parent)
    : QObject(parent) {
}

QString UserInfoModel::username() const {
    return m_userInfo.username;
}

QString UserInfoModel::token() const {
    return m_userInfo.token;
}

int UserInfoModel::softcore_score() const {
    return m_userInfo.softcore_score;
}

int UserInfoModel::hardcore_score() const {
    return m_userInfo.hardcore_score;
}

QUrl UserInfoModel::pfp() const {
    return m_userInfo.pfp;
}

bool UserInfoModel::hardcore() const {
    return m_userInfo.hardcore;
}

QUrl UserInfoModel::link() const {
    return m_userInfo.link;
}

int UserInfoModel::width() const {
    return m_userInfo.width;
}

int UserInfoModel::height() const {
    return m_userInfo.height;
}

bool UserInfoModel::savestates() const {
    return m_userInfo.savestates;
}

bool UserInfoModel::cheats() const {
    return m_userInfo.cheats;
}

bool UserInfoModel::patched() const {
    return m_userInfo.patched;
}

bool UserInfoModel::autohardcore() const {
    return m_userInfo.autohardcore;
}

bool UserInfoModel::compact() const {
    return m_userInfo.compact;
}

bool UserInfoModel::ingamehooks() const
{
    return m_userInfo.ingamehooks;
}

bool UserInfoModel::banner() const
{
    return m_userInfo.banner;
}

void UserInfoModel::username(const QString& u)
{
    m_userInfo.username = u;
    emit dataChanged();
}

void UserInfoModel::token(const QString& t)
{
    m_userInfo.token = t;
    emit dataChanged();
}

void UserInfoModel::softcore_score(const int& s)
{
    m_userInfo.softcore_score = s;
    emit dataChanged();
}

void UserInfoModel::hardcore_score(const int& hs)
{
    m_userInfo.hardcore_score = hs;
    emit dataChanged();
}

void UserInfoModel::pfp(const QUrl& p)
{
    m_userInfo.pfp = p;
    emit dataChanged();
}

void UserInfoModel::hardcore(const bool& h)
{
    m_userInfo.hardcore = h;
    emit dataChanged();
}

void UserInfoModel::link(const QUrl& l)
{
    m_userInfo.link = l;
    emit dataChanged();
}

void UserInfoModel::width(const int& w)
{
    m_userInfo.width = w;
}

void UserInfoModel::height(const int& h)
{
    m_userInfo.height = h;
}

void UserInfoModel::savestates(const bool& s)
{
    m_userInfo.savestates = s;
}

void UserInfoModel::cheats(const bool& c)
{
    m_userInfo.cheats = c;
}

void UserInfoModel::patched(const bool& p)
{
    m_userInfo.patched = p;
}

void UserInfoModel::autohardcore(const bool& a)
{
    m_userInfo.autohardcore = a;
    emit dataChanged();
}

void UserInfoModel::compact(const bool& c)
{
    m_userInfo.compact = c;
}

void UserInfoModel::ingamehooks(const bool& n)
{
    m_userInfo.ingamehooks = n;
}

void UserInfoModel::banner(const bool& b)
{
    m_userInfo.banner = b;
}

void UserInfoModel::clearUser() {
    m_userInfo = UserInfo();
}
