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
    channel = "stable";
    version = "3.3.10";
    filename = "flutter_linux_${version}-${channel}.tar.xz";
    sha256Hash = "sha256-0k6D96a4KdFj/u7xq/zDCGnwxdGvk+mRdCYmXa1QcCQ=";
    patches = getPatches ./patches/dev;
  };
}
