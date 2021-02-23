{ channel, pname, version, sha256Hash, patches
, filename ? "flutter_linux_v${version}-${channel}.tar.xz"
}:

{ bash, unzip, curl, buildFHSUserEnv, cacert, coreutils, git, makeWrapper, runCommand, stdenv
, fetchurl, alsaLib, dbus, expat, libpulseaudio, libuuid, libGL, nspr, nss, systemd }:

let
  drvName = "flutter-${channel}-${version}";
  flutter = stdenv.mkDerivation {
    name = "${drvName}-online";

    src = fetchurl {
      url =
        "https://storage.googleapis.com/flutter_infra/releases/${channel}/linux/${filename}";
      sha256 = sha256Hash;
    };
    buildInputs = [ curl unzip cacert git ];
    postPatch = ''
      patchShebangs --build ./bin/
      find ./bin/ -executable -type f -exec patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) {} \;
    '';
    installPhase = ''
      mkdir -p $out
      cp -r . $out
    '';
  };

  # Wrap flutter inside an fhs user env to allow execution of binary,
  # like adb from $ANDROID_HOME or java from android-studio.
  fhsEnv = buildFHSUserEnv {
    name = "${drvName}-fhs-env";
    multiPkgs = pkgs: [
      # Flutter only use these certificates
      (runCommand "fedoracert" { } ''
        mkdir -p $out/etc/pki/tls/
        ln -s ${cacert}/etc/ssl/certs $out/etc/pki/tls/certs
      '')
      pkgs.zlib
    ];
    targetPkgs = pkgs:
      with pkgs; [
        bash
        curl
        git
        unzip
        which
        xz

        # for web
        google-chrome

        # for desktop
        pkg-config
        clang
        cmake
        ninja
        pkg-config
        gtk3
        glib
        pango
        harfbuzz
        cairo
        gdk-pixbuf
        atk
        utillinux
        pcre
        xorg.libX11
        xorg.xorgproto
        xorg.libxcb
        xorg.xtrans
        epoxy
        libselinux

        # flutter test requires this lib
        libGLU

        # for android emulator
        alsaLib
        dbus
        expat
        libpulseaudio
        libuuid
        xorg.libxcb
        xorg.libXcomposite
        xorg.libXcursor
        xorg.libXdamage
        xorg.libXfixes
        libGL
        nspr
        nss
        systemd
      ];
      extraOutputsToInstall = [ "dev" ];
      profile = ''
        export CHROME_EXECUTABLE=/usr/bin/google-chrome-stable

        pkg-config --print-errors --exists gtk+-3.0 || echo "GTK 3 Not found"
        pkg-config --print-errors --exists glib-2.0 || echo "GLib 2.0 Not found"
        pkg-config --print-errors --exists gio-2.0 || echo "GIO 2.0 Not found"
      '';
  };

in runCommand drvName {
  startScript = ''
    #!${bash}/bin/bash
    export PUB_CACHE=''${PUB_CACHE:-"$HOME/.pub-cache"}
    export ANDROID_EMULATOR_USE_SYSTEM_LIBS=1
    ${fhsEnv}/bin/${drvName}-fhs-env $FLUTTER_SDK/bin/flutter --no-version-check "$@"
  '';
  preferLocalBuild = true;
  allowSubstitutes = false;
  passthru = { unwrapped = flutter; };
  meta = with stdenv.lib; {
    description =
      "Flutter is Google's SDK for building mobile, web and desktop with Dart.";
    longDescription = ''
      Flutter is Google’s UI toolkit for building beautiful,
      natively compiled applications for mobile, web, and desktop from a single codebase.
    '';
    homepage = "https://flutter.dev";
    license = licenses.bsd3;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ babariviere ];
  };
} ''
  mkdir -p $out/bin

  echo -n "$startScript" > $out/bin/${pname}
  chmod +x $out/bin/${pname}
''
