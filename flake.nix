{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = {nixpkgs, flake-utils, ...}: flake-utils.lib.eachDefaultSystem (system:
    let pkgs = import nixpkgs {
          inherit system;
        };
        plasma-applet-caraoke = (with pkgs;
          stdenv.mkDerivation {
            pname = "plasma-applet-caraoke";
            version = "0.0.1";
            src = ./.;

            buildInputs = (with pkgs.kdePackages; [
              kwindowsystem
              # plasma-framework
            ]) ++ (with pkgs; [qt6.full])
            ;

            nativeBuildInputs = [extra-cmake-modules];
            buildPhase = "make -j $NIX_BUILD_CORES";
            dontWrapQtApps = true;
          });
        dontWrapQtApps = true;
    in rec {
      defaultApp = flake-utils.lib.mkApp {
        drv = defaultPackage;
      };
      defaultPackage = plasma-applet-caraoke;
      devShell = pkgs.mkShell {
        buildInputs = [
          plasma-applet-caraoke.buildInputs
          plasma-applet-caraoke.nativeBuildInputs
          pkgs.kdePackages.plasma-sdk
        ];
      };
    }
  );
}
