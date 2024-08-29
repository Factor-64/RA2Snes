#include "ra_client.h"

rc_client_t* g_client = NULL;

// This is the function the rc_client will use to read memory for the emulator. we don't need it yet,
// so just provide a dummy function that returns "no memory read".
uint32_t read_memory(uint32_t address, uint8_t* buffer, uint32_t num_bytes, rc_client_t* client)
{
    //return getMemoryAddress(address, buffer, num_bytes);
    //return getAddress(unsigned int addr, unsigned int size, Space space = SNES);
    qDebug() << "Address: " << address << " Num of Bytes: " << num_bytes;
    return 0;
}

// This is the callback function for the asynchronous HTTP call (which is not provided in this example)
void http_callback(int status_code, const char* content, size_t content_size, void* userdata, const char* error_message)
{
    // Prepare a data object to pass the HTTP response to the callback
    rc_api_server_response_t server_response;
    memset(&server_response, 0, sizeof(server_response));
    server_response.body = content;
    server_response.body_length = content_size;
    server_response.http_status_code = status_code;

    // handle non-http errors (socket timeout, no internet available, etc)
    if (status_code == 0 && error_message) {
        // assume no server content and pass the error through instead
        server_response.body = error_message;
        server_response.body_length = strlen(error_message);
        // Let rc_client know the error was not catastrophic and could be retried. It may decide to retry or just
        // immediately pass the error to the callback. To prevent possible retries, use RC_API_SERVER_RESPONSE_CLIENT_ERROR.
        server_response.http_status_code = RC_API_SERVER_RESPONSE_RETRYABLE_CLIENT_ERROR;
    }

    // Get the rc_client callback and call it
    async_callback_data* async_data = (async_callback_data*)userdata;
    async_data->callback(&server_response, async_data->callback_data);
    // Release the captured rc_client callback data
    free(async_data);
}

// This is the HTTP request dispatcher that is provided to the rc_client. Whenever the client
// needs to talk to the server, it will call this function.
void server_call(const rc_api_request_t* request,
                 rc_client_server_callback_t callback, void* callback_data, rc_client_t* client)
{
    // RetroAchievements may not allow hardcore unlocks if we don't properly identify ourselves.
    const char* user_agent = "ra2snes/1.0";

    // callback must be called with callback_data, regardless of the outcome of the HTTP call.
    // Since we're making the HTTP call asynchronously, we need to capture them and pass it
    // through the async HTTP code.
    async_callback_data* async_data = (async_callback_data*) malloc(sizeof(async_callback_data));
    async_data->callback = callback;
    async_data->callback_data = callback_data;

    // If post data is provided, we need to make a POST request, otherwise, a GET request will suffice.
    if (request->post_data)
        async_http_post(request->url, request->post_data, request->content_type, user_agent, http_callback, async_data);
    else
        async_http_get(request->url, user_agent, http_callback, async_data);
}

void async_http_post(const char* url, const char* post_data, const char* content_type, const char* user_agent, void (*callback)(int, const char*, size_t, void*, const char*), void* userdata)
{
    QNetworkAccessManager* manager = new QNetworkAccessManager();
    QNetworkRequest request(QUrl(QString::fromUtf8(url)));
    request.setHeader(QNetworkRequest::ContentTypeHeader, QString::fromUtf8(content_type));
    request.setRawHeader("User-Agent", user_agent);

    QNetworkReply* reply = manager->post(request, QByteArray(post_data));
    QObject::connect(reply, &QNetworkReply::finished, [reply, callback, userdata]() {
        int status_code = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        QByteArray response_data = reply->readAll();
        callback(status_code, response_data.data(), response_data.size(), userdata, reply->errorString().toUtf8().data());

        reply->deleteLater();
    });

    QObject::connect(manager, &QNetworkAccessManager::finished, manager, &QNetworkAccessManager::deleteLater);
}

void async_http_get(const char* url, const char* user_agent, void (*callback)(int, const char*, size_t, void*, const char*), void* userdata)
{
    QNetworkAccessManager* manager = new QNetworkAccessManager();
    QNetworkRequest request(QUrl(QString::fromUtf8(url)));
    request.setRawHeader("User-Agent", user_agent);

    QNetworkReply* reply = manager->get(request);
    QObject::connect(reply, &QNetworkReply::finished, [reply, callback, userdata]() {
        int status_code = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        QByteArray response_data = reply->readAll();
        callback(status_code, response_data.data(), response_data.size(), userdata, reply->errorString().toUtf8().data());

        reply->deleteLater();
    });

    QObject::connect(manager, &QNetworkAccessManager::finished, manager, &QNetworkAccessManager::deleteLater);
}

// Write log messages to the console
void log_message(const char* message, const rc_client_t* client)
{
    qDebug() << message;
}

static void event_handler(const rc_client_event_t* event, rc_client_t* client)
{
    qDebug() << "Event! " << event->type;
}

void initialize_retroachievements_client(void)
{
    // Create the client instance (using a global variable simplifies this example)
    g_client = rc_client_create(read_memory, server_call);

    // Provide a logging function to simplify debugging
    rc_client_enable_logging(g_client, RC_CLIENT_LOG_LEVEL_VERBOSE, log_message);

    // Provide an event handler
    rc_client_set_event_handler(g_client, event_handler);
    // Disable hardcore - if we goof something up in the implementation, we don't want our
    // account disabled for cheating.
    rc_client_set_hardcore_enabled(g_client, 0);
}

void shutdown_retroachievements_client(void)
{
    if (g_client)
    {
        // Release resources associated to the client instance
        rc_client_destroy(g_client);
        g_client = NULL;
    }
}

static void login_callback(int result, const char* error_message, rc_client_t* client, void* userdata)
{
    // If not successful, just report the error and bail.
    if (result != RC_OK)
    {
        qDebug() << "Login failed:" << error_message << result;
        return;
    }

    // Login was successful. Capture the token for future logins so we don't have to store the password anywhere.
    const rc_client_user_t* user = rc_client_get_user_info(client);
    //store_retroachievements_credentials(user->username, user->token);

    // Inform user of successful login
    qDebug() << "Logged in as" << user->display_name << user->score;
}

void login_retroachievements_user(const char* username, const char* password)
{
    // This will generate an HTTP payload and call the server_call chain above.
    // Eventually, login_callback will be called to let us know if the login was successful.
    rc_client_begin_login_with_password(g_client, username, password, login_callback, NULL);
}

void login_remembered_retroachievements_user(const char* username, const char* token)
{
    // This is exactly the same functionality as rc_client_begin_login_with_password, but
    // uses the token captured from the first login instead of a password.
    // Note that it uses the same callback.
    rc_client_begin_login_with_token(g_client, username, token, login_callback, NULL);
}

static void load_game_callback(int result, const char* error_message, rc_client_t* client, void* userdata)
{
    if (result != RC_OK)
    {
        qDebug() << "RetroAchievements game load failed:" << error_message;
        return;
    }

    // announce that the game is ready. we'll cover this in the next section.
    qDebug() << result << "Success!";
    show_game_placard();
}

void load_snes_game(const uint8_t* rom, size_t rom_size)
{
    // this example is hard-coded to identify a Super Nintendo game already loaded in memory.
    // it will use the rhash library to generate a hash, then make a server call to resolve
    // the hash to a game_id. If found, it will then fetch the game data and start a session
    // for the user. By the time load_game_callback is called, the achievements for the game are
    // ready to be processed (unless an error occurs, like not being able to identify the game).
    rc_client_begin_identify_and_load_game(g_client, RC_CONSOLE_SUPER_NINTENDO,
                                           NULL, rom, rom_size, load_game_callback, NULL);
}

void load_gameboy_game(const uint8_t* rom, size_t rom_size)
{
    // this example uses RC_CONSOLE_UNKNOWN, which tells the rc_client to attempt to determine
    // the system associated to the game from the filename and contents of the file. If the
    // console is known, it's always preferred to pass it in.
    rc_client_begin_identify_and_load_game(g_client, RC_CONSOLE_GAMEBOY,
                                           NULL, rom, rom_size, load_game_callback, NULL);
}

static void show_game_placard(void)
{
    char message[128], url[128];
    //async_image_data* image_data = NULL;
    const rc_client_game_t* game = rc_client_get_game_info(g_client);
    rc_client_user_game_summary_t summary;
    rc_client_get_user_game_summary(g_client, &summary);

    // Construct a message indicating the number of achievements unlocked by the user.
    if (summary.num_core_achievements == 0)
    {
        snprintf(message, sizeof(message), "This game has no achievements.");
    }
    else if (summary.num_unsupported_achievements)
    {
        snprintf(message, sizeof(message), "You have %u of %u achievements unlocked (%d unsupported).",
                 summary.num_unlocked_achievements, summary.num_core_achievements,
                 summary.num_unsupported_achievements);
    }
    else
    {
        snprintf(message, sizeof(message), "You have %u of %u achievements unlocked.",
                 summary.num_unlocked_achievements, summary.num_core_achievements);
    }

    // The emulator is responsible for managing images. This uses rc_client to build
    // the URL where the image should be downloaded from.
    if (rc_client_game_get_image_url(game, url, sizeof(url)) == RC_OK)
    {
        // Generate a local filename to store the downloaded image.
        char game_badge[64];
        snprintf(game_badge, sizeof(game_badge), "game_%s.png", game->badge_name);

        // This function will download and cache the game image. It is up to the emulator
        // to implement this logic. Similarly, the emulator has to use image_data to
        // display the game badge in the placard, or a placeholder until the image is
        // downloaded. None of that logic is provided in this example.
        //image_data = download_and_cache_image(game_badge, url);
    }

    //show_popup_message(image_data, game->title, message);
}

/*void show_achievements_menu(void)
{
    char url[128];
    const char* progress;

    // This will return a list of lists. Each top-level item is an achievement category
    // (Active Challenge, Unlocked, etc). Empty categories are not returned, so we can
    // just display everything that is returned.
    rc_client_achievement_list_t* list = rc_client_create_achievement_list(g_client,
                                                                           RC_CLIENT_ACHIEVEMENT_CATEGORY_CORE_AND_UNOFFICIAL,
                                                                           RC_CLIENT_ACHIEVEMENT_LIST_GROUPING_PROGRESS);

    // Clear any previously loaded menu items
    menu_reset();

    for (int i = 0; i < list->num_buckets; i++)
    {
        // Create a header item for the achievement category
        menu_append_item(NULL, list->buckets[i].label, "");

        for (int j = 0; j < list->buckets[i].num_achievements; j++)
        {
            const rc_client_achievement_t* achievement = list->buckets[i].achievements[j];
            async_image_data* image_data = NULL;

            if (rc_client_achievement_get_image_url(achievement, achievement->state, url, sizeof(url)) == RC_OK)
            {
                // Generate a local filename to store the downloaded image.
                char achievement_badge[64];
                snprintf("ach_%s%s.png", achievement->badge_name,
                         (state == RC_CLIENT_ACHIEVEMENT_STATE_UNLOCKED) ? "" : "_lock");
                image_data = download_and_cache_image(achievement_badge, url);
            }

            // Determine the "progress" of the achievement. This can also be used to show
            // locked/unlocked icons and progress bars.
            if (list->buckets[i].id == RC_CLIENT_ACHIEVEMENT_BUCKET_UNSUPPORTED)
                progress = "Unsupported";
            else if (achievement->unlocked)
                progress = "Unlocked";
            else if (achievement->measured_percent)
                progress = achievement->measured_progress;
            else
                progress = "Locked";

            menu_append_item(image_data, achievement->title, achievement->description, progress);
        }
    }

    rc_client_destroy_achievement_list(list);
}*/
