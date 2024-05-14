{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          overlays = [ ];
          pkgs = import nixpkgs {
            inherit system overlays;
          };
        in
        with pkgs;
        {
          devShells.default =
            mkShell
              {
                # General stuff
                name = "pyroscope-app";
                nativeBuildInputs = [
                  yarn
                  nodejs_20
                ];
              };

        }
      );
}
