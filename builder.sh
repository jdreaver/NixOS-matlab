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
activationPropertiesFile=$_activation_file
" >> $_input_file

for product in $activatedProducts; do
    echo product.$product >> $_input_file
done

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

REPLACE_FILES=(
    $out/bin/matlab
    $out/bin/activate_matlab.sh
    $out/bin/mcc
)

for f in ${REPLACE_FILES[*]}; do
    substituteInPlace $f\
        --replace /bin/pwd $(type -P pwd)\
        --replace /bin/echo $(type -P echo)
done

PATCH_FILES=(
    $out/bin/glnxa64/MATLAB
    $out/sys/java/jre/glnxa64/jre/bin/java
    $out/bin/glnxa64/need_softwareopengl
    $out/bin/glnxa64/mcc
)

for f in ${PATCH_FILES[*]}; do
    patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
       --set-rpath "$libPath:$(patchelf --print-rpath $f)"\
       --force-rpath $f
done
