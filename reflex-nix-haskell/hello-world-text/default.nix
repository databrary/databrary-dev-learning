{ 
}:

let
  reflex-platform = import
    ((import <nixpkgs> {}).fetchFromGitHub {
      owner= "reflex-frp";
      repo = "reflex-platform";
      rev = "bdc94c605bf72f1a65cbd12075fbb661e28b24ea";
      sha256 = "1i4zk7xc2x8yj9ms4gsg70immm29dp8vzqq7gdzxig5i3kva0a61";
  }) {};
  # Definition of nixpkgs, version controlled by Reflex-Platform
  nixpkgs = reflex-platform.nixpkgs;
  inherit (nixpkgs) fetchFromGitHub;
  # nixpkgs functions used to regulate Haskell overrides
  inherit (nixpkgs.haskell.lib) dontCheck overrideCabal doJailbreak;
  # Define GHC compiler override
  pkgs = reflex-platform.ghc.override {
    overrides = self: super: rec {
      hello-world-text = self.callPackage ./hello-world-text.nix {};
    };
  };
in { hello-world-text = pkgs.hello-world-text; }
