{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };

        jdk = pkgs.jdk17;
        sharedDependencies = with pkgs; [jdk gradle];
        linuxDependencies = with pkgs; [];
        macosDependencies = with pkgs; [];
        macosFrameworks = with pkgs.darwin.apple_sdk.frameworks; [];

        dependencies =
          sharedDependencies
          ++ pkgs.lib.optionals pkgs.stdenv.isLinux linuxDependencies
          ++ pkgs.lib.optionals pkgs.stdenv.isDarwin macosDependencies
          ++ pkgs.lib.optionals pkgs.stdenv.isDarwin macosFrameworks;
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; dependencies ++ [];
          env = {
            LD_LIBRARY_PATH = pkgs.lib.strings.makeLibraryPath dependencies;
          };
        };
      }
    );
}
