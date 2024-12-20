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

      shells = {
        python = {
          path = ./shells/python;
          description = "Python development shell template, using pdm.";
        };

        java = {
          path = ./shells/java;
          description = "Java development shell template, using gradle.";
        };

        csharp = {
          path = ./shells/csharp;
          description = "Dotnet and C# development shell template.";
        };

        generic = {
          path = ./shells/generic;
          description = "Generic development shell template.";
        };
      };
    };
  };
}
