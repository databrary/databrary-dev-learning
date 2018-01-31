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
  zipSrc = fetchFromGitHub {
        owner= "databrary";
        repo = "zip";
        rev = "bd0c8d3bf9b06a8c0f3c13e8c234042a52234290";
        sha256 = "1cjzv89piw3vjm6jh9n1psbfrlkv9x2hi3b2cb6z1ss2wxlzwaml";
  };
  # Define GHC compiler override
  pkgs = reflex-platform.ghc.override {
    overrides = self: super: rec {
      hello-world = self.callPackage ./hello-world.nix {};
      # gargoyle = self.callPackage "${gargoyleSrc}/gargoyle" {};
      # Define zip with special fork including streaming support; dontCheck to save time
      zip = dontCheck (self.callPackage "${zipSrc}" {});
    };
  };
in { hello-world = pkgs.hello-world; }
