{
  lib,
  appimageTools,
  fetchurl,
  stdenvNoCC,
  # makeWrapper,
  ...
}:
let
  inherit (stdenvNoCC.hostPlatform) system;

  pname = "wechat";
  meta = {
    description = "Messaging and calling app";
    homepage = "https://www.wechat.com/en/";
    downloadPage = "https://linux.weixin.qq.com/en";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ hastyshell ];
    mainProgram = "wechat";
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];
  };

  sources = {
    aarch64-linux = {
      version = "4.1.0.13";
      src = fetchurl {
        url = "https://web.archive.org/web/20251106024910/https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_arm64.AppImage";
        hash = "sha256-/d5crM6IGd0k0fSlBSQx4TpIVX/8iib+an0VMkWMNdw=";
      };
    };
    x86_64-linux = {
      version = "4.1.0.13";
      src = fetchurl {
        url = "https://web.archive.org/web/20251106024907/https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.AppImage";
        hash = "sha256-+r5Ebu40GVGG2m2lmCFQ/JkiDsN/u7XEtnLrB98602w=";
      };
    };
  };

  inherit (sources.${system} or (throw "Unsupported system: ${system}")) version src;

  appimageContents = appimageTools.extract {
    inherit pname version src;
    postExtract = ''
      patchelf --replace-needed libtiff.so.5 libtiff.so $out/opt/wechat/wechat
    '';
  };
in
appimageTools.wrapAppImage {
  inherit pname version meta;

  src = appimageContents;

  # nativeBuildInputs = [ makeWrapper ];

  # note:
  # It is vital to exec wechat with command
  # sh -c "${pname} > /tmp/wechat.log 2>&1"
  # since wechat seems to need a stdout/stderr
  # otherwise it cannot start with app launcher
  # properly, or can only run with Terminal=true.
  # It sucks!
  extraInstallCommands = ''
    # wrapProgram $out/bin/${pname} \
    #    --set GTK_IM_MODULE "fcitx" \
    #    --set QT_IM_MODULE "fcitx" \
    #    --set QT_QPA_PLATFORM "xcb"
    #    --set QT_AUTO_SCREEN_SCALE_FACTOR 1.5

    mkdir -p $out/share/icons/hicolor/256x256/apps
    cp ${appimageContents}/wechat.png $out/share/icons/hicolor/256x256/apps/

    mkdir -p $out/share/applications

    cat > $out/share/applications/${pname}.desktop <<EOF
    [Desktop Entry]
    Exec=sh -c "${pname} > /tmp/wechat.log 2>&1"
    Icon=wechat
    Name=wechat
    Terminal=false
    Type=Application
    Version=4.0.13
    EOF
  '';

  # Add these root paths to FHS sandbox to prevent WeChat from accessing them by default
  # Adapted from https://aur.archlinux.org/cgit/aur.git/tree/wechat-universal.sh?h=wechat-universal-bwrap
  extraPreBwrapCmds = ''
    WECHAT_PERSIST_DIR="''${HOME}/.xwechat"

    WECHAT_DATA_DIR="''${WECHAT_PERSIST_DIR}/WeChat_Data"

    # Using ''${WECHAT_DATA_DIR} as Wechat Data folder
    WECHAT_HOME_DIR="''${WECHAT_DATA_DIR}/home"
    WECHAT_FILES_DIR="''${WECHAT_DATA_DIR}/xwechat_files"

    mkdir -p "''${WECHAT_FILES_DIR}"
    mkdir -p "''${WECHAT_HOME_DIR}"
    ln -snf "''${WECHAT_FILES_DIR}" "''${WECHAT_HOME_DIR}/xwechat_files"
  '';
  extraBwrapArgs = [
    "--tmpfs /home"
    "--tmpfs /root"
    # format: --bind <host-path> <sandbox-path>
    "--bind \${WECHAT_HOME_DIR} \${HOME}"
    "--bind \${WECHAT_FILES_DIR} \${WECHAT_FILES_DIR}"
    "--chdir \${HOME}"
    # wechat-universal only supports xcb
    "--setenv QT_QPA_PLATFORM xcb"
    # "--setenv QT_AUTO_SCREEN_SCALE_FACTOR 1"
    "--setenv QT_SCALE_FACTOR 1.25"
    # use fcitx as IME
    "--setenv QT_IM_MODULE fcitx"
    "--setenv GTK_IM_MODULE fcitx"
  ];
  chdirToPwd = false;
  unshareNet = false;
  unshareIpc = true;
  unsharePid = true;
  unshareUts = true;
  unshareCgroup = true;
  privateTmp = true;
}
