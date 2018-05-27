{ mkDerivation, base, stdenv, text }:
mkDerivation {
  pname = "hello-world-text";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [ base text ];
  executableHaskellDepends = [ base text ];
  testHaskellDepends = [ base text ];
  homepage = "https://github.com/githubuser/hello-world#readme";
  license = stdenv.lib.licenses.bsd3;
}
