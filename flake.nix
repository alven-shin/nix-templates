{
  description = "My customized flake templates";

  outputs = {self}: {
    templates = {
      rust = {
        path = ./rust;
        description = "Modified Rust template with custom Cargo configs.";
      };
      leptos-csr = {
        path = ./leptos-csr;
        description = "A Modified Modified Rust template for client-side rendering leptos";
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
