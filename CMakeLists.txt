cmake_minimum_required(VERSION 3.16)

project(ra2snes VERSION 1.0 LANGUAGES C CXX)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(QT NAMES Qt6 REQUIRED COMPONENTS Core LinguistTools WebSockets Quick Qml QuickWidgets QuickLayouts QuickControls2 Widgets)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core LinguistTools WebSockets Quick Qml QuickWidgets QuickLayouts QuickControls2 Widgets)

set(TS_FILES ra2snes_en_US.ts)

file(GLOB UI_FILES ${CMAKE_SOURCE_DIR}/ui/*)
file(GLOB UI_IMAGES ${CMAKE_SOURCE_DIR}/ui/images/*)

set(RCHEEVOS_SOURCES
    ${CMAKE_SOURCE_DIR}/rcheevos/src/rc_compat.c
    ${CMAKE_SOURCE_DIR}/rcheevos/src/rc_client.c
    ${CMAKE_SOURCE_DIR}/rcheevos/src/rc_util.c
    ${CMAKE_SOURCE_DIR}/rcheevos/src/rc_version.c
    ${CMAKE_SOURCE_DIR}/rcheevos/src/rcheevos/alloc.c
    ${CMAKE_SOURCE_DIR}/rcheevos/src/rcheevos/condition.c
    ${CMAKE_SOURCE_DIR}/rcheevos/src/rcheevos/condset.c
    ${CMAKE_SOURCE_DIR}/rcheevos/src/rcheevos/consoleinfo.c
    ${CMAKE_SOURCE_DIR}/rcheevos/src/rcheevos/format.c
    ${CMAKE_SOURCE_DIR}/rcheevos/src/rcheevos/lboard.c
    ${CMAKE_SOURCE_DIR}/rcheevos/src/rcheevos/memref.c
    ${CMAKE_SOURCE_DIR}/rcheevos/src/rcheevos/operand.c
    ${CMAKE_SOURCE_DIR}/rcheevos/src/rcheevos/rc_validate.c
    ${CMAKE_SOURCE_DIR}/rcheevos/src/rcheevos/richpresence.c
    ${CMAKE_SOURCE_DIR}/rcheevos/src/rcheevos/runtime.c
    ${CMAKE_SOURCE_DIR}/rcheevos/src/rcheevos/runtime_progress.c
    ${CMAKE_SOURCE_DIR}/rcheevos/src/rcheevos/trigger.c
    ${CMAKE_SOURCE_DIR}/rcheevos/src/rcheevos/value.c
    ${CMAKE_SOURCE_DIR}/rcheevos/src/rapi/rc_api_common.c
    ${CMAKE_SOURCE_DIR}/rcheevos/src/rapi/rc_api_editor.c
    ${CMAKE_SOURCE_DIR}/rcheevos/src/rapi/rc_api_info.c
    ${CMAKE_SOURCE_DIR}/rcheevos/src/rapi/rc_api_runtime.c
    ${CMAKE_SOURCE_DIR}/rcheevos/src/rapi/rc_api_user.c
)

add_library(rcheevos STATIC ${RCHEEVOS_SOURCES})
target_include_directories(rcheevos PUBLIC
    ${CMAKE_SOURCE_DIR}/rcheevos/include
    ${CMAKE_SOURCE_DIR}/rcheevos/src
    ${CMAKE_SOURCE_DIR}/rcheevos/src/rcheevos
    ${CMAKE_SOURCE_DIR}/rcheevos/src/rapi
)

target_compile_definitions(rcheevos PRIVATE RC_DISABLE_LUA)

if(MSVC)
    target_compile_options(rcheevos PRIVATE /W4)
    target_compile_options(rcheevos PRIVATE /wd4244 /wd4245)
else()
    set_source_files_properties(${RCHEEVOS_SOURCES} PROPERTIES
        COMPILE_FLAGS "-Wall -Wextra -Wshadow -pedantic -fno-signed-char -std=c99 -Wno-unused-but-set-variable"
    )
    target_compile_options(rcheevos PRIVATE -Werror -Wno-long-long -Wno-error=implicit-function-declaration)
    target_compile_definitions(rcheevos PRIVATE _POSIX_C_SOURCE=200809L)
endif()


set(PROJECT_SOURCES
    ${UI_FILES}
    ${UI_IMAGES}
    main.cpp
    ra2snes.cpp
    ra2snes.h
    ${TS_FILES}
    usb2snes.cpp
    usb2snes.h
    raclient.cpp
    raclient.h
    memoryreader.cpp
    memoryreader.h
    rastructs.h
    ra2snes.qrc
    achievementmodel.cpp
    achievementmodel.h
    achievementsortfilterproxymodel.cpp
    achievementsortfilterproxymodel.h
    gameinfomodel.cpp
    gameinfomodel.h
    userinfomodel.cpp
    userinfomodel.h
    version.h
    networkcachemanager.cpp
    networkcachemanager.h
)

if(WIN32)
    set(PROJECT_SOURCES ${PROJECT_SOURCES} ${CMAKE_SOURCE_DIR}/ra2snes.rc)
endif()

add_library(miniz STATIC miniz/miniz.c)
target_include_directories(miniz PUBLIC ${CMAKE_SOURCE_DIR}/miniz)

add_executable(updater
  updater_main.cpp
  updater.cpp
  updater.h
)
target_link_libraries(updater PRIVATE
    miniz
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::Network
    Qt${QT_VERSION_MAJOR}::Widgets
)
target_include_directories(updater PRIVATE
    ${CMAKE_SOURCE_DIR}/include
)

if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    qt_add_executable(ra2snes
        MANUAL_FINALIZATION
        ${PROJECT_SOURCES}
    )
    qt_create_translation(QM_FILES ${CMAKE_SOURCE_DIR} ${TS_FILES})
else()
    if(ANDROID)
        add_library(ra2snes SHARED ${PROJECT_SOURCES})
    else()
        add_executable(ra2snes ${PROJECT_SOURCES})
    endif()
    qt5_create_translation(QM_FILES ${CMAKE_SOURCE_DIR} ${TS_FILES})
endif()

target_link_libraries(ra2snes PRIVATE
    rcheevos
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::WebSockets
    Qt${QT_VERSION_MAJOR}::Quick
    Qt${QT_VERSION_MAJOR}::Qml
    Qt${QT_VERSION_MAJOR}::QuickWidgets
)

target_include_directories(ra2snes PRIVATE
    ${CMAKE_SOURCE_DIR}/rcheevos/include
    ${CMAKE_SOURCE_DIR}/rcheevos/src
    ${CMAKE_SOURCE_DIR}/rcheevos/src/rapi
    ${CMAKE_SOURCE_DIR}/rcheevos/src/rcheevos
    ${CMAKE_SOURCE_DIR}/rcheevos/src/rhash
    ${CMAKE_SOURCE_DIR}/rcheevos/src/rurl
)

if(${QT_VERSION} VERSION_LESS 6.1.0)
  set(BUNDLE_ID_OPTION MACOSX_BUNDLE_GUI_IDENTIFIER com.example.ra2snes)
endif()

set_target_properties(ra2snes PROPERTIES
    ${BUNDLE_ID_OPTION}
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

set_target_properties(updater PROPERTIES
    WIN32_EXECUTABLE TRUE
)

install(TARGETS ra2snes updater
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

if(QT_VERSION_MAJOR EQUAL 6)
    qt_finalize_executable(ra2snes)
endif()
