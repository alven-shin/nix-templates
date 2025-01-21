{
  description = "My customized flake templates";

  outputs = {self}: {
    templates = {
      rust = {
        path = ./rust;
        description = "Modified Rust template with custom Cargo configs.";
      };
      cpp = {
        path = ./cpp;
        description = "C++ template with CMake, adapted from https://gitlab.com/CLIUtils/modern-cmake/.";
      };
      generic = {
        path = ./generic;
        description = "Generic development shell template.";
      };
    };
  };
}
