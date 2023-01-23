# To update nix-prefetch-git https://github.com/NixOS/nixpkgs-channels
import ((import <nixpkgs> {}).fetchFromGitHub {
  owner = "NixOS";
  repo = "nixpkgs";
  rev = "6d378c3747fd03b5dc45215c11e904e296a12cc2";
  sha256  = "sha256-pGLj5X4+8iOT57M9OV3w1+BAAd4EEyo7Hsz09PcYoKU=";
})
