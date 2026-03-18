{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        # Create wrapper for x86_64-linux-gnu-gcc (without -unknown-)
        # Use runCommand to avoid stdenv's build infrastructure
        x86_64GccWrapper = pkgs.runCommand "x86_64-linux-gnu-gcc-wrapper" { } ''
          mkdir -p $out/bin
          set -x
          for tool in ${pkgs.pkgsCross.gnu64.stdenv.cc}/bin/x86_64-unknown-linux-gnu-*; do
            if [ -f "$tool" ]; then
              basename=$(basename $tool)
              newname=$(echo $basename | sed 's/x86_64-unknown-linux-gnu-/x86_64-linux-gnu-/')
              ln -s $tool $out/bin/$newname
            fi
          done
          exit 1
        '';

        # Create wrapper for aarch64-linux-gnu-gcc (without -unknown-)
        # Use runCommand to avoid stdenv's build infrastructure
        aarch64GccWrapper = pkgs.runCommand "aarch64-linux-gnu-gcc-wrapper" { } ''
          mkdir -p $out/bin
          for tool in ${pkgs.pkgsCross.aarch64-multiplatform.stdenv.cc}/bin/aarch64-unknown-linux-gnu-*; do
            if [ -f "$tool" ]; then
              basename=$(basename $tool)
              newname=$(echo $basename | sed 's/aarch64-unknown-linux-gnu-/aarch64-linux-gnu-/')
              ln -s $tool $out/bin/$newname
            fi
          done
        '';

        llvmToolsWrapper17 = pkgs.runCommand "suffix-17-wrapper" { } ''
          mkdir -p $out/bin

          ln -s "${pkgs.llvmPackages_17.bintools}/bin/llc" $out/bin/llc-17
          ln -s "${pkgs.llvmPackages_17.bintools}/bin/llvm-link" $out/bin/llvm-link-17
        '';
      in
      {
        devShells.default = pkgs.mkShell
          {
            packages = with pkgs; [
              protobuf
              cmake
              go
              llvmPackages_17.clang-unwrapped
              llvmPackages_17.bintools
              pkgs.pkgsCross.aarch64-multiplatform.stdenv.cc
              pkgs.pkgsCross.gnu64.stdenv.cc
              x86_64GccWrapper
              aarch64GccWrapper
              llvmToolsWrapper17
            ];
          };
      }
    );
}
