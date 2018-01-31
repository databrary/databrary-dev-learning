{ mkDerivation, base, stdenv, zip }:
mkDerivation {
  pname = "hello-world";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [ base zip ];
  executableHaskellDepends = [ base zip ];
  testHaskellDepends = [ base zip ];
  homepage = "https://github.com/githubuser/hello-world#readme";
  license = stdenv.lib.licenses.bsd3;
}
