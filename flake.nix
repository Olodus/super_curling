# Node2nix for wasm4
# How node2nix suggests for creating a derivation from a node package.
#let
#  pkgs = import sources.nixpkgs { };
#  nodeDependencies = (pkgs.callPackage ./default.nix {}).shell.nodeDependencies;
#in
#
#stdenv.mkDerivation {
#  name = "super_curling";
#  src = ./src;
#  buildInputs = [nodejs];
#
#  buildPhase = ''
#    ln -s ${nodeDependencies}/lib/node_modules ./node_modules
#    export PATH="${nodeDependencies}/bin:$PATH"
#
#    # Build the distribution bundle in "dist"
#    zig build -Drelease-small=true
#    w4 run zig-out/lib/cart.wasm
#    cp -r dist $out/
#  '';
#}

# Flake for Super Curling

{
  description = "A flake for building and running the Super Curling game";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    napalm.url = "github:nix-community/napalm"; # Used for building npm packages
    # If I decide to nix-ilize wasm4 separetely (maybe for possible upstream merge) I should use my own fork until I have got it working
    wasm4.url = "github:aduros/wasm4/master";
    wasm4.flake = false;
    #wasm4.url = "github:Olodus/wasm4/master"; 
  }

  outputs = { self, ...}@inputs: {
    let
      napalm = pkgs.callPackage <napalm> {};
    in napalm.buildPackage ./. { packageLock = 
    overlay = final: prev: {
      wasm4-deps = final.napalm.buildPackage . 
    defaultPackage.web =
      with import nixpkgs { system = "web"; };
      stdenv.mkDerivation {
        name = "super_curling";
        src = self;
        buildInputs = [zig napalm wasm4];
        buildPhase = ''
          zig build -Drelease-small=true
          w4 bundle zig-out/lib/cart.wasm --title "Super Curling" --html result/web/super_curling.html
        '';
        #installPhase = "
      };
  };
}
