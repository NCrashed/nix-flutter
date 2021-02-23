self: super:
rec {
  flutterPackages =
    self.recurseIntoAttrs (self.callPackage ./default.nix { });
  flutter = flutterPackages.stable;
}
