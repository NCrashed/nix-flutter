/* ~/.config/nixpkgs/config.nix
{
  ...
  android_sdk.accept_license = true;
} */
{ pkgs ? import ./pkgs.nix {
    config = {
      allowUnfree = true;
      android_sdk.accept_license = true;
    };
    overlays = [ (import ./flutter/overlay.nix) ];
  } }:
let
  android-nixpkgs-src = builtins.fetchGit {
    url = "https://github.com/tadfisher/android-nixpkgs.git";
    rev = "e348d1e0bb8b172496f691dd0ebc091ac7c032ec";
  };
  android-nixpkgs = pkgs.callPackage android-nixpkgs-src {
    # Default; can also choose "beta", "preview", or "canary".
    channel = "stable";
  };
  android-sdk = android-nixpkgs.sdk (sdkPkgs: with sdkPkgs; [
    cmdline-tools-latest
    build-tools-32-0-0
    platform-tools
    platforms-android-31
    emulator
  ]);
in pkgs.mkShell {
    nativeBuildInputs = with pkgs; with android-nixpkgs; [
      flutterPackages.dev

      android-sdk
      jdk
      git
      clang
      cmake
      ninja
      pkg-config
      gtk3.dev
      utillinux.dev
    ];

    shellHook=''
      export USE_CCACHE=1
      export ANDROID_JAVA_HOME=${pkgs.jdk.home}
      export ANDROID_HOME=~/.android-sdk 
      if [ ! -d "$ANDROID_HOME" ]
      then
        cp -r ${android-sdk}/share/android-sdk ~/.android-sdk
        chmod u+rws -R ~/.android-sdk
      fi
      export ANDROID_SDK_ROOT=$ANDROID_HOME
      export FLUTTER_SDK=~/.flutter-sdk
      export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools

      ln -s $ANDROID_JAVA_HOME ~/Android/Sdk/jre || true

      if [ ! -d "$FLUTTER_SDK" ]
      then
          echo "Creating $FLUTTER_SDK"
          mkdir -p $FLUTTER_SDK
          cp -r ${pkgs.flutterPackages.dev.unwrapped}/. $FLUTTER_SDK
          chmod -R u+w ~/.flutter-sdk
      fi

      echo -e "\e[0;32mWelcome to Project Aboba Development\e[m"
      echo -e "Path to the Flutter SDK to enter in android-studio:"
      echo -e "\e[0;34m$FLUTTER_SDK\e[m"

      echo -e "It is advised to add \e[1;34mprograms.adb.enable = true;\e[m to your nix configuration"
      echo -e "Furthermore, add your user to the \e[1;34madbusers\e[m group."
    '';
  }
