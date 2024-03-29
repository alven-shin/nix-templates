{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    naersk.url = "github:nix-community/naersk";
    flake-utils.url = "github:numtide/flake-utils";
    rustyaura.url = "github:OwOSwordsman/rustyaura.nix";
  };

  outputs = {
    self,
    nixpkgs,
    rust-overlay,
    naersk,
    flake-utils,
    rustyaura,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        overlays = [(import rust-overlay)];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        # https://github.com/oxalica/rust-overlay#cheat-sheet-common-usage-of-rust-bin
        toolchain = pkgs.rust-bin.selectLatestNightlyWith (
          toolchain:
            toolchain.default.override {
              targets = ["wasm32-unknown-unknown"];
              extensions = ["rust-src"];
            }
        );
        # NOTE: use this instead if using rust-toolchain file
        # toolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;

        naersk' = pkgs.callPackage naersk {
          cargo = toolchain;
          rustc = toolchain;
        };

        sharedDependencies = with pkgs; [toolchain sccache];
        linuxDependencies = with pkgs; [clang mold];
        macosDependencies = with pkgs; [lld_16];
        macosFrameworks = with pkgs.darwin.apple_sdk.frameworks; [];

        dependencies =
          sharedDependencies
          ++ pkgs.lib.optionals pkgs.stdenv.isLinux linuxDependencies
          ++ pkgs.lib.optionals pkgs.stdenv.isDarwin macosDependencies
          ++ pkgs.lib.optionals pkgs.stdenv.isDarwin macosFrameworks;
      in {
        packages.default = naersk'.buildPackage {
          src = ./.;
          buildInputs = dependencies;
          RUSTC_WRAPPER = "";
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs;
            dependencies
            ++ [
              trunk
              just
              tailwindcss
              rustyaura.packages.${system}.rustyaura
            ];
          env = {
            LD_LIBRARY_PATH = pkgs.lib.strings.makeLibraryPath dependencies;
          };
        };
      }
    );
}
