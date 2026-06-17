{
  description = "pyroscope-ai-bench development shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.buildEnv {
          name = "pyroscope-ai-bench-env";
          paths = [ pkgs.uv pkgs.mise ];
        };

        devShells.default = pkgs.mkShell {
          packages = [ pkgs.uv pkgs.mise ];
        };
      }
    );
}
