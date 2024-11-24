{pkgs, ...}: rec {
  nativeBuildInputs = with pkgs; [
    cmake
    ninja
    cppcheck
    just
  ];

  buildInputs = with pkgs; [
  ];

  all = nativeBuildInputs ++ buildInputs;
}
