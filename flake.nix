{
  description = "My customized flake templates";

  outputs = {self}: {
    templates = {
      rust = {
        path = ./rust;
        description = "Modified Rust template with custom Cargo configs";
      };

      java-basic = {
        path = ./java-basic;
        description = "A basic Java template.";
      };
    };
  };
}
