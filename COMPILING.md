## Windows

1) Install Qt 6.9.1 and Qt Creator using the [qt-online-installer](https://www.qt.io/download-qt-installer)
2) Clone the repo
    ```
    git clone https://github.com/Factor-64/RA2Snes.git --recursive
    ```
3) Open the CMakeFile as a project in Qt Creator (the builds and releases use MSVC).
4) Build and Run

## Linux

1) Clone the repo
    ```
    git clone https://github.com/Factor-64/RA2Snes.git --recursive
    ```
2) Install Dependencies
    ```
   sudo apt-get install -y build-essential cmake git qt6-tools-dev qt6-websockets-dev \
        qml6-module-qtquick qml6-module-qtquick-controls qml6-module-qtquick-layouts \
        qml6-module-qtquick-templates qml6-module-qtquick-window qt6-declarative-dev \
        qml6-module-qtqml-workerscript qml6-module-qtmultimedia qml6-module-qt-labs-folderlistmodel \
        qml6-module-qt5compat-graphicaleffects libqt6svg6 libqt6websockets6 libqt6qml6 libqt6gui6
    ```
3) Setup with CMake
    ```
    cd RA2Snes
    cmake -S . -B build -DCMake_PREFIX_PATH=/usr/lib/x86_64-linux-gnu/cmake/Qt6
    ```
4) Build
    ```
    cmake --build build --config Release
    ```
5) Run
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
