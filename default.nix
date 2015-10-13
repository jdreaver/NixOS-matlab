with import <nixpkgs> { };

let
  fileInstallationKey="XXXXX-XXXXX-XXXXX-XXXXX";
  version = "R2014b";
  filename = "MATLAB-Linux64.tar";
  activatedProducts = [
    "MATLAB"
    "MATLAB_Compiler"
  ];
in

stdenv.mkDerivation {
  name = "matlab-${version}";
  builder = ./builder.sh;

  src = fetchurl {
   url = "file:///tmp/${filename}";
   sha256 = "2013893803cf1f1981ec73e6f4278f2bb9271818741ed38a6f15e4e20674fc06";
  };

  licenseFile = ./license.lic;
  fileInstallationKey = fileInstallationKey;
  activatedProducts = activatedProducts;

  inherit gcc48;

  buildInputs = [
    gcc48
    makeWrapper
  ];

  libPath = stdenv.lib.makeLibraryPath [
    ncurses
    xorg.libXi
    xorg.libXext
    xorg.libXmu
    xorg.libXp
    xorg.libXpm
    xorg.libXrandr
    xorg.libXrender
    xorg.libXt
    xorg.libXtst
    xorg.libXxf86vm
    xorg.libX11
    zlib
  ];

}
