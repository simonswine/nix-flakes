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
            config.allowUnfree = true;
          };
          myvscode = pkgs.vscode-with-extensions.override {
            vscodeExtensions = with pkgs.vscode-extensions; [
              ms-dotnettools.csharp
              ms-dotnettools.csdevkit
            ];
          };

        in
        with pkgs;
        {
          devShells.default =
            mkShell
              {
                # General stuff
                name = "pyroscope-dotnet";
                nativeBuildInputs = [
                  myvscode
                  dotnet-sdk
                ];
              };

        }
      );
}
