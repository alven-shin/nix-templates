{
  description = "My customized flake templates";

  outputs = {self}: {
    templates = {
      rust = {
        path = ./rust;
        description = "Modified Rust template, using sccache and lld.";
      };

      java-basic = {
        path = ./java-basic;
        description = "A basic Java template.";
      };
    };
  };
}
