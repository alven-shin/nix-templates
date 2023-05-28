{
  description = "My customized flake templates";

  outputs = {self}: {
    templates = {
      python = {
        path = ./python;
        description = "Python development shell template, using pdm";
      };
    };
  };
}
