{
  description = "3dxdisp development flake";

  inputs = {
    nixpkgs = {
      url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.zst";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    in
    inputs.flake-utils.lib.eachSystem systems (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        lib = pkgs.lib;
        relativePathSubstitution = ''
          substituteInPlace Makefile \
            --replace-fail "../lib3dxdisp.a" "${self.packages.${system}.driver}/lib/lib3dxdisp.a"
        '';
        spacepilotDisplayMeta = {
          description = "A program for dumping a 1 bit monochrome image to a 3dconnexion spacepilot display";
          license = lib.licenses.agpl3Only;
          platforms = lib.platforms.linux;
          mainProgram = "spacepilotdisplay";
        };
      in
      {
        packages = {
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
              self.packages.${system}.driver
              pkgs.udev.dev
            ];

            postPatch = relativePathSubstitution;

            installPhase = ''
              runHook preInstall
              mkdir -p $out/bin
              cp example $out/bin/draw3dxdisplogo
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

              meta = {
                description = "An image manipulation library";
                license = lib.licenses.mit;
                platforms = lib.platforms.linux;
              };
            };

          threedximage = pkgs.stdenv.mkDerivation {
            pname = "3dximage";
            version = "0-unstable-2025-02-17";
            src = ./3dximage;

            buildInputs = [
              self.packages.${system}.driver
              self.packages.${system}.libimago
              pkgs.udev
            ];

            postPatch = relativePathSubstitution;

            installPhase = ''
              runHook preInstall
              mkdir -p $out/bin
              cp 3dximage $out/bin
              runHook postInstall
            '';

            meta = {
              description = "An program for displaying arbitery images on a 3dconnexion spacepilot display";
              license = lib.licenses.mit;
              platforms = lib.platforms.linux;
              mainProgram = "3dximage";
            };
          };

          spacepilotDisplay = lib.makeOverridable (
            {
              jamlytics ? false,
            }:
            pkgs.stdenv.mkDerivation {
              pname = "spacepilotdisplay";
              version = "1.0.0";
              src = ./spacepilotdisplay;

              makeFlags = [
                "PREFIX=$(out)"
                "INSTALL_ASSETS=${if jamlytics then "1" else "0"}"
              ];

              buildInputs = [
                self.packages.${system}.driver
                pkgs.udev.dev
              ];

              postPatch = relativePathSubstitution;

              meta = spacepilotDisplayMeta;
            }
          ) { };

          jamlytics = self.packages.${system}.spacepilotDisplay.override {
            jamlytics = true;
          };

          default = pkgs.lib.makeOverridable (
            {
              jamlytics ? false,
            }:
            pkgs.symlinkJoin {
              name = "3dxdisp";
              paths = [
                self.packages.${system}.driver
                self.packages.${system}.example
                (self.packages.${system}.spacepilotDisplay.override { inherit jamlytics; })
              ];
            }
          ) { };
        };
        apps = {
          example = {
            type = "app";
            program = "${self.packages.${system}.example}/bin/draw3dxdisplogo";
          };
          jamlytics =
            let
              spacepilotDisplayWithAssets = self.packages.${system}.spacepilotDisplay.override {
                jamlytics = true;
              };
            in
            {
              type = "app";
              program = "${pkgs.writeShellScript "draw-jamlytics-logo-to-spacepilot" "${spacepilotDisplayWithAssets}/bin/spacepilotdisplay ${spacepilotDisplayWithAssets}/share/jamlytics.packed"}";
              meta = spacepilotDisplayMeta;
            };
          default = self.apps.${system}.example;
        };
      }
    );
}
