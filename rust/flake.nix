{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    naersk.url = "github:nix-community/naersk";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    rust-overlay,
    naersk,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        overlays = [(import rust-overlay)];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        # https://github.com/oxalica/rust-overlay#cheat-sheet-common-usage-of-rust-bin
        toolchain = pkgs.rust-bin.stable.latest.default;
        # NOTE: use this instead if using rust-toolchain file
        # toolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain;

        naersk' = pkgs.callPackage naersk {
          cargo = toolchain;
          rustc = toolchain;
        };

        linuxDependencies = with pkgs; [toolchain sccache mold];
        macosDependencies = with pkgs; [toolchain sccache];
        macosFrameworks = with pkgs.darwin.apple_sdk.frameworks; [];

        dependencies =
          pkgs.lib.optionals pkgs.stdenv.isLinux linuxDependencies
          ++ pkgs.lib.optionals pkgs.stdenv.isDarwin macosDependencies
          ++ pkgs.lib.optionals pkgs.stdenv.isDarwin macosFrameworks;
      in {
        packages.default = naersk'.buildPackage {
          src = ./.;
          buildInputs = dependencies;
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs;
            dependencies ++ [rust-analyzer taplo];
          env = {
            LD_LIBRARY_PATH = pkgs.lib.strings.makeLibraryPath dependencies;
          };
        };
      }
    );
}
