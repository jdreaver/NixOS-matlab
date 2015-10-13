# NixOS Matlab Installation

This is a way to install Matlab on a NixOS machine. Matlab is hard to install
on NixOS, primarily because

1. It has opaque dependencies.
2. It ships bundled with tons of libraries, but some of these expect external
   libraries.
3. It expects a normal Unix file structure.

This is still a **work in progress**, so please file and issue or make a pull
request if something doesn't work. I will also revise this README as I learn
more about the installation.

# Usage

1. Enter your file installation key, matlab version, and installation file name
   in the default.nix file
2. Go into builder.sh and change your installed Matlab packages in the
   `_input_file` variable. (Note that product.MATLAB is required)
3. Put your license.lic file in your current directory.
4. Copy your installer file to the /tmp directory. (Why? nix chokes when
   [large files are in the source tree](https://github.com/NixOS/nix/issues/358).
   Therefore, we need to use fetchurl, and we need the files in a place the
   builder can access.)
4. Run `nix-build default.nix`

# Tips

## XMonad, AwesomeWM, and maybe others

If Matlab appears as just a grey window, then you need to trick matlab into
thinking you are using a different window manager. Install the `wmname` program
and then type `wmname LG3D`. This works for a few java programs.

# TODO

* Don't require a tar file (allow zip)
* Make configuration simple for users. Put all needed user info at the top of
  default.nix with comments and skeleton values.
* Test mcc, mbuild, and mex to make sure they can find gcc correctly.
* Use requireFile instead of forcing the user to put their installer file in
  /tmp
* Add builder for Matlab Compiler Runtime
