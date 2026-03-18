{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ ];
        pkgs = import nixpkgs {
          inherit system overlays;
          config.allowUnfree = true;
        };

        openssl = pkgs.pkgsStatic.openssl;
      in
      with pkgs;
      {
        devShells.default = mkShell {
          # General stuff
          name = "pyroscope-dotnet";
          nativeBuildInputs = [
            dotnet-sdk
            clang
            cmake
            openssl.dev
            pkg-config

            # required by libunwind
            autoconf
            automake
            libtool
          ];

          shellHook = ''
            # Use clang instead of gcc
            export CMAKE_C_COMPILER=clang
            export CMAKE_CXX_COMPILER=clang++
            export CC=clang
            export CXX=clang++

            # Point cmake to static openssl
            export "OPENSSL_ROOT_DIR=${openssl.out}"

            # Compat with older cmake versions
            export CMAKE_POLICY_VERSION_MINIMUM=3.5

            export CMAKE_BUILD_TYPE=Debug
            export CMAKE_CXX_FLAGS_DEBUG="-g -O0"
            export CMAKE_C_FLAGS_DEBUG="-g -O0"
          '';
        };

      }
    );
}
