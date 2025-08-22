{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    cmake
    gcc          # or clang
    git
    qt6.full      # provides Qt6, qml modules and developer tools
    pkg-config
    vulkan-loader             # runtime
    vulkan-headers            # provides Vulkan_INCLUDE_DIR
    vulkan-tools              # optional useful tools
    qt6.qtdeclarative
    qt6.qtwebsockets
    qt6.qtmultimedia
    qt6.qtsvg
  ];

  # If you need qmake/cmake helpers:
  QT_PLUGIN_PATH = "${pkgs.qt6.qtbase}/lib/qt6/plugins";
}