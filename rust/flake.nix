{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";

    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    rust-overlay,
    flake-utils,
    crane,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        overlays = [(import rust-overlay)];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        # https://github.com/oxalica/rust-overlay#cheat-sheet-common-usage-of-rust-bin
        toolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = ["rust-src"];
        };
        # NOTE: use this instead if using rust-toolchain file
        # toolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain;

        sharedDependencies = with pkgs; [sccache];
        linuxDependencies = with pkgs; [mold clang];
        macosDependencies = with pkgs; [];
        macosFrameworks = with pkgs.darwin.apple_sdk.frameworks; [];

        dependencies =
          sharedDependencies
          ++ pkgs.lib.optionals pkgs.stdenv.isLinux linuxDependencies
          ++ pkgs.lib.optionals pkgs.stdenv.isDarwin macosDependencies
          ++ pkgs.lib.optionals pkgs.stdenv.isDarwin macosFrameworks;

        craneLib = (crane.mkLib pkgs).overrideToolchain toolchain;
        sharedCrateArgs = {
          src = craneLib.cleanCargoSource (craneLib.path ./.);
          strictDeps = true;
          buildInputs = dependencies;
          RUSTC_WRAPPER = "";
        };
        crate-release = craneLib.buildPackage sharedCrateArgs;
        crate-dev = craneLib.buildPackage (sharedCrateArgs
          // {
            CARGO_PROFILE = "dev";
          });
      in {
        packages.default = crate-release;
        packages.dev = crate-dev;

        checks = {
          crate = crate-dev;
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [toolchain] ++ dependencies;
          env = {
            LD_LIBRARY_PATH = pkgs.lib.strings.makeLibraryPath dependencies;
          };
        };
      }
    );
}
