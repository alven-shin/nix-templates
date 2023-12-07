{
  self,
  lib,
  ...
}: {
  perSystem = {
    config,
    self',
    inputs',
    pkgs,
    ...
  }: let
    deps = import ./dependencies.nix {inherit pkgs self';};
  in {
    devShells.default = pkgs.mkShell {
      packages = with pkgs;
        [
          curl
          git
          just
          bacon
        ]
        ++ deps.all;
    };
  };
}
