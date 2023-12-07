{
  pkgs,
  self',
  ...
}: let
  kubos = import ./kubos.nix {
    inherit pkgs;
  };
  toolchain =
    pkgs
    .rust-bin
    .stable
    .${
      if pkgs.stdenv.isDarwin
      then "1.49.0"
      else "1.39.0"
    }
    .default
    .override {
      extensions = ["rust-src"];
    };
in rec {
  nativeBuildInputs = with pkgs;
    [
      toolchain
      openssl
      pkg-config
    ]
    ++ lib.optionals stdenv.isDarwin
    (with darwin.apple_sdk.frameworks; [Security]);

  buildInputs = with pkgs; [
    (python38.withPackages (ps: [
      (kubos.app_api ps)
      (kubos.kubos_service ps)
    ]))
    sqlite
  ];

  all = nativeBuildInputs ++ buildInputs;
}
