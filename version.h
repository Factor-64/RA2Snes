#ifndef VERSION_H
#define VERSION_H

#include <QString>

// Define version components
#define RA2SNES_VERSION_MAJOR 1
#define RA2SNES_VERSION_MINOR 1
#define RA2SNES_VERSION_PATCH 1

// Combine components into a string
#define RA2SNES_VERSION_STRING QString("%1.%2.%3").arg(RA2SNES_VERSION_MAJOR).arg(RA2SNES_VERSION_MINOR).arg(RA2SNES_VERSION_PATCH)

// Define repository information
#define RA2SNES_REPO_OWNER "Factor-64"
#define RA2SNES_REPO_NAME "ra2snes"
#define RA2SNES_REPO_URL QString("%1/%2").arg(RA2SNES_REPO_OWNER, RA2SNES_REPO_NAME)

#endif // VERSION_H
