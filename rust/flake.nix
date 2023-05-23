{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    rust-overlay,
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
        rust =
          if builtins.pathExists ./rust-toolchain
          then pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain
          else if builtins.pathExists ./rust-toolchain.toml
          then pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml
          else pkgs.rust-bin.stable.latest.default;

        compileTimeDependencies = with pkgs; [rust sccache lld];
        runtimeDependencies = with pkgs; [];
      in {
        defaultPackage = let
          name = let
            config =
              builtins.fromTOML (builtins.readFile ./Cargo.toml);
          in
            config.package.name;
        in
          pkgs.stdenv.mkDerivation {
            inherit name;
            src = ./.;
            nativeBuildInputs = compileTimeDependencies;
            buildInputs = runtimeDependencies;
            buildPhase = "cargo build --release";
            installPhase = ''
              mkdir -p $out/bin
              cp target/release/${name} $out/bin
            '';
          };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs;
            compileTimeDependencies
            ++ runtimeDependencies
            ++ [rust-analyzer taplo];
        };
      }
    );
}
