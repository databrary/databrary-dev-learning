with (import <nixpkgs> {});
derivation {
  name = "foo";
  builder = "${bash}/bin/bash";
  args = [ ./builder.sh ];
  system = builtins.currentSystem;
}