{
  description = "3dxdisp development flake";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.zst";
  };

  outputs = inputs: {
    packages = builtins.mapAttrs (
      system: pkgs:
      let
        self = inputs.self.packages.${system};
        relativePathSubstitution = ''
          substituteInPlace Makefile \
            --replace-fail "../lib3dxdisp.a" "${self.driver}/lib/lib3dxdisp.a"
        '';
      in
      {
        driver = pkgs.stdenv.mkDerivation {
          pname = "3dxdisp";
          version = "0-unstable-2026-02-17";
          src = pkgs.lib.cleanSource ./.;

          makeFlags = [
            "PREFIX=$(out)"
            "DESTDIR="
          ];

          buildInputs = [ pkgs.udev.dev ];
        };

        example = pkgs.stdenv.mkDerivation {
          pname = "3dxdisp-example";
          version = "0-unstable-2018-08-18";
          src = ./example;

          buildInputs = [
            self.driver
            pkgs.udev.dev
          ];

          postPatch = relativePathSubstitution;

          installPhase = ''
            runHook preInstall
            mkdir -p $out/draw-3dxdisp-logo
            cp example $out
            runHook postInstall
          '';
        };

        libimago =
          let
            pname = "libimago";
            version = "2.4.2";
          in
          pkgs.stdenv.mkDerivation {
            inherit pname version;
            src = pkgs.fetchFromGitHub {
              owner = "jtsiomb";
              repo = pname;
              tag = "v${version}";
              hash = "sha256-os7S5gnfvf2WhUIH3E/1ONdNewbkOpa4jq6oB9tq8mI=";
            };

            buildInputs = with pkgs; [
              libjpeg
              libpng
            ];
          };

        threedximage = pkgs.stdenv.mkDerivation {
          pname = "3dximage";
          version = "0-unstable-2025-02-17";
          src = ./3dximage;

          buildInputs = [
            self.driver
            self.libimago
            pkgs.udev.dev
          ];

          postPatch = relativePathSubstitution;

          installPhase = ''
            runHook preInstall
            mkdir -p $out
            cp 3dximage $out
            runHook postInstall
          '';
        };

        default = pkgs.symlinkJoin {
          name = "3dxdisp";
          paths = [
            self.driver
            self.example
          ];
        };
      }
    ) inputs.nixpkgs.legacyPackages;
  };
}
