{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          overlays = [
            (
              self: super: {
                yarn = super.yarn.override {
                  nodejs = pkgs.nodejs_22;
                };
              }
            )
          ];
          pkgs = import nixpkgs {
            inherit system overlays;
          };

          recursiveMerge =
            with nixpkgs.lib;
            attrList:
            let
              f = attrPath:
                zipAttrsWith (n: values:
                  if tail values == [ ]
                  then head values
                  else if all isList values
                  then unique (concatLists values)
                  else if all isAttrs values
                  then f (attrPath ++ [ n ]) values
                  else last values
                );
            in
            f [ ] attrList;

        in
        with pkgs;
        {
          devShells.default =
            mkShell (recursiveMerge [
              {
                # General stuff
                name = "pyroscope";

                nativeBuildInputs = [
                  buf
                  pkg-config
                ];

                buildInputs = [
                  go_1_24
                ];

              }
              {
                # Frontend stuff
                nativeBuildInputs = [ yarn nodejs_20 wget ];
                buildInputs = [
                  pixman
                  cairo
                  libpng
                  pango
                  glib.dev
                  harfbuzz.dev
                  freetype.dev
                  python3
                ];
              }
              {
                # Examples rust stuff
                buildInputs = [ libiconv ];
              }
            ]);

        }
      );
}
