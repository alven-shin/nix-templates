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
        sharedDependencies = with pkgs; [jdk makeWrapper];
        linuxDependencies = with pkgs; [];
        macosDependencies = with pkgs; [];
        macosFrameworks = with pkgs.darwin.apple_sdk.frameworks; [];

        dependencies =
          sharedDependencies
          ++ pkgs.lib.optionals pkgs.stdenv.isLinux linuxDependencies
          ++ pkgs.lib.optionals pkgs.stdenv.isDarwin macosDependencies
          ++ pkgs.lib.optionals pkgs.stdenv.isDarwin macosFrameworks;
      in {
        defaultPackage = let
          name = "Main"; # NOTE: replace with program name
          entrypoint = name; # NOTE: replace if name != classfile with main method
        in
          pkgs.stdenv.mkDerivation {
            inherit name;
            src = ./src;
            buildInputs = dependencies;
            buildPhase = "${jdk}/bin/javac -d $out/share/${name} ${entrypoint}.java";
            installPhase = ''
              makeWrapper ${jdk}/bin/java $out/bin/${name} \
                --add-flags "-cp $out/share/${name}" \
                --add-flags "${entrypoint}"
            '';
          };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; dependencies ++ [];
          env = {
            LD_LIBRARY_PATH = pkgs.lib.strings.makeLibraryPath dependencies;
          };
        };
      }
    );
}
