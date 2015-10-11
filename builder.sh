source $stdenv/setup

# Pre-installation tasks like unpacking, changing path names, and using
# patchelf on binary files
echo "Unpacking source..."
tar xfa $src
cd MATLAB-Linux64/*

echo "Patching install files..."
substituteInPlace install \
   --replace /bin/pwd $(type -P pwd)
substituteInPlace bin/glnxa64/install_unix \
   --replace /bin/pwd $(type -P pwd)

# Create the silent installer files
_input_file=$(pwd)/_installer_input.txt
_activation_file=$(pwd)/_activation.ini
echo "
destinationFolder=$out
agreeToLicense=yes
mode=silent
fileInstallationKey=$fileInstallationKey
product.MATLAB
product.MATLAB_Compiler
activationPropertiesFile=$_activation_file
" >> $_input_file

echo "
isSilent=True
activateCommand=activateOffline
licenseFile=$licenseFile
installLicenseFileDir=$out/licenses
installLicenseFileName=license.lic
" >> $_activation_file

mkdir -p $out/licenses

echo "Patching java..."
patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
  --set-rpath "$libPath:$(patchelf --print-rpath sys/java/jre/glnxa64/jre/bin/java)"\
  --force-rpath "sys/java/jre/glnxa64/jre/bin/java"

# Run the installer with the generated input file
echo "Running installer..."
export MATLAB_ARCH=glnxa64
./install -inputFile $_input_file

# Run patchelf and substituteInPlace on various files in the output
echo "Patching output..."
substituteInPlace $out/bin/matlab \
   --replace /bin/pwd $(type -P pwd)

substituteInPlace $out/bin/activate_matlab.sh \
   --replace /bin/pwd $(type -P pwd)

substituteInPlace $out/bin/mcc \
   --replace /bin/pwd $(type -P pwd)\
   --replace /bin/echo $(type -P echo)\

patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
  --set-rpath "$libPath:$(patchelf --print-rpath $out/bin/glnxa64/MATLAB)"\
  --force-rpath $out/bin/glnxa64/MATLAB

patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
  --set-rpath "$libPath:$(patchelf --print-rpath $out/sys/java/jre/glnxa64/jre/bin/java)"\
  --force-rpath "$out/sys/java/jre/glnxa64/jre/bin/java"

patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
   "$out/bin/glnxa64/need_softwareopengl"

patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
  --set-rpath "$libPath:$(patchelf --print-rpath $out/bin/glnxa64/mcc)"\
  --force-rpath $out/bin/glnxa64/mcc

# echo "LD_LIBRARY_PATH=$libPath ./matlab" >> $out/bin/ld_matlab
