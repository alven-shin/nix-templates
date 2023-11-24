{
  self,
  lib,
  inputs,
  ...
}: {
  perSystem = {
    config,
    self',
    inputs',
    pkgs,
    ...
  }: let
    deps = import ./dependencies.nix {inherit pkgs;};

    craneLib = (inputs.crane.mkLib pkgs).overrideToolchain deps.toolchain;
    sharedCrateArgs = {
      src = craneLib.cleanCargoSource (craneLib.path ../.);
      strictDeps = true;
      inherit (deps) buildInputs nativeBuildInputs;
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
  };
}
