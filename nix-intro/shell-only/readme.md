# taken from http://lethalman.blogspot.it/2014/07/nix-pill-7-working-derivation.html with prior pill about installing nix-repl
Install repl:
nix-env -i nix-repl

Start repl installed:
nix-repl

# bring all packages into scope
> :l <nixpkgs>

# check for bash location
> "${bash}"

# create a derivation
> d = derivation { name = "foo"; builder = "${bash}/bin/bash"; args = [ ./builder.sh ]; system = builtins.currentSystem; }

# build it, observe output in nix-store  (build = instantiate + store realize)
> :b d

# observe the same, but with a nix build file. exit out of repl, run
$ nix-build foo.nix

# try nix shell with foo's build environment
$ nix-shell foo.nix
$ echo $out
$ echo $builder

# create a build for short c program (see simple*); run produced program
$ nix-build simple.nix
$ result/simple



# .... how to create bash scripts that use the bash in the build env?

# start nix shell, use gcc interactively
$ nix-shell simple.nix
> echo $gcc
> $gcc/bin/gcc
> ls $coreutils/bin/

# write a script that uses the tools mentioned above
