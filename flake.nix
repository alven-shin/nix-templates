{
  description = "My customized flake templates";

  outputs = {self}: {
    templates = {
      rust = {
        path = ./rust;
        description = "Modified rust template, using Naersk, sccache, and lld.";
      };
    };
  };
}
