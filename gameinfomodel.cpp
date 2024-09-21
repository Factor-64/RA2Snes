#include "GameInfoModel.h"

GameInfoModel::GameInfoModel(QObject *parent) : QObject(parent) {}

void GameInfoModel::setGameInfo(const GameInfo &gameInfo) {
    m_gameInfo = gameInfo;
    emit dataChanged();
}

QString GameInfoModel::title() const {
    return m_gameInfo.title;
}

QString GameInfoModel::md5hash() const {
    return m_gameInfo.md5hash;
}

unsigned int GameInfoModel::id() const {
    return m_gameInfo.id;
}

QString GameInfoModel::image_icon() const {
    return m_gameInfo.image_icon;
}

QUrl GameInfoModel::image_icon_url() const {
    return m_gameInfo.image_icon_url;
}

QUrl GameInfoModel::game_link() const {
    return m_gameInfo.game_link;
}

QString GameInfoModel::console() const {
    return m_gameInfo.console;
}

QUrl GameInfoModel::console_icon() const {
    return m_gameInfo.console_icon;
}

unsigned int GameInfoModel::completion_count() const {
    return m_gameInfo.completion_count;
}

void GameInfoModel::updateCompletionCount() {
    m_gameInfo.completion_count++;
    emit dataChanged();
}

void GameInfoModel::clearGame() {
    m_gameInfo = GameInfo();
}