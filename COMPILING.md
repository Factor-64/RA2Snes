## Windows

1) Install Qt 6.9.0 and Qt Creator using the [qt-online-installer](https://www.qt.io/download-qt-installer)
2) Clone the repo
    ```
    git clone https://github.com/Factor-64/ra2snes.git --recursive
    ```
4) Compile rcheevos using MingW64 (either the one built into Qt or using your installation)
    ```
    cd RA2Snes/rcheevos/test
    make ARCH=x64 BUILD=c89 CC=gcc HAVE_HASH=0 test
    ```
6) Open the CMakeFile as a project in Qt Creator.
7) Build and Run

## Linux

1) Install Dependencies
    ```
    sudo apt-get install -y build-essential cmake qt6-tools-dev qt6-websockets-dev qml6-module-qtquick qml6-module-qtquick-controls qml6-module-qtquick-layouts qml6-module-qtquick-templates qml6-module-qtquick-window qt6-declarative-dev qml6-module-qtqml-workerscript qml6-module-qtmultimedia qml6-module-qt-labs-folderlistmodel qml6-module-qtquick-effects libqt6svg6 libva-dev libva-glx2 libva-drm2 libgstreamer1.0-dev
    ```
    If you are having issues with your version of Linux finding `qml6-module-qtquick-effects` try these commands:
    ```
    echo "deb http://archive.ubuntu.com/ubuntu/ oracular main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
    sudo apt-get update
    sudo apt-get install build-essential cmake qt6-tools-dev qt6-websockets-dev qml6-module-qtquick qml6-module-qtquick-controls qml6-module-qtquick-layouts qml6-module-qtquick-templates qml6-module-qtquick-window qt6-declarative-dev qml6-module-qtqml-workerscript qml6-module-qtmultimedia qml6-module-qt-labs-folderlistmodel qml6-module-qtquick-effects libqt6svg6 libva-dev libva-glx2 libva-drm2 libgstreamer1.0-dev
    sudo sed -i '/oracular/d' /etc/apt/sources.list
    ```
2) Clone the repo
    ```
    git clone https://github.com/Factor-64/ra2snes.git --recursive
    ```
4) Compile rcheevos
    ```
    cd RA2Snes/rcheevos/test
    make ARCH=x64 BUILD=c89 CC=gcc HAVE_HASH=0 test
    ```
5) Setup with CMake
    ```
    cd RA2Snes
    cmake -S . -B build -DCMake_PREFIX_PATH=/usr/lib/x86_64-linux-gnu/cmake/Qt6
    ```

6) Build
    ```
    cmake --build build --config Release
    ```
7) Run
   ```
   cd build
   chmod +x ra2snes
   ./ra2snes
   ```
Rebuilding
   ```
   cmake --build build --target clean
   cmake -S . -B build -DCMake_PREFIX_PATH=/usr/lib/x86_64-linux-gnu/cmake/Qt6
   cmake --build build --config Release
   ```
