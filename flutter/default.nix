{ callPackage, fetchurl }:

let
  mkFlutter = opts: callPackage (import ./flutter.nix opts) { };
  getPatches = dir:
    let files = builtins.attrNames (builtins.readDir dir);
    in map (f: dir + ("/" + f)) files;
in {
  mkFlutter = mkFlutter;
  dev = mkFlutter rec {
    pname = "flutter";
    channel = "dev";
    version = "1.27.0-1.0.pre";
    filename = "flutter_linux_${version}-${channel}.tar.xz";
    sha256Hash = "1qa767rxwxzzv0xfw3vs48cqab7fhmw4dhnmw8g0q7z11k9wicw9";
    patches = getPatches ./patches/dev;
  };
}
