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
        compileTimeDependencies = with pkgs; [];

        runtimeDependencies = with pkgs; [];
      in {
        defaultPackage = let
          name = "Main"; # NOTE: replace with program name
          entrypoint = name; # NOTE: replace if name != classfile with main method
        in
          pkgs.stdenv.mkDerivation {
            inherit name;
            src = ./src;
            nativeBuildInputs = compileTimeDependencies;
            buildInputs = runtimeDependencies;
            buildPhase = "${jdk}/bin/javac -d $out/share/${name} ${entrypoint}.java";
            installPhase = ''
              mkdir -p $out/bin
              echo -e "#!/bin/bash\n${jdk}/bin/java -cp $out/share/${name} ${entrypoint}" > $out/bin/${name}
              chmod +x $out/bin/${name}
            '';
          };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs;
            compileTimeDependencies
            ++ runtimeDependencies
            ++ [jdt-language-server];
        };
      }
    );
}
