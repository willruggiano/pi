{
  nixfmt,
  treefmt,
  ...
}:
treefmt.withConfig {
  runtimeInputs = [
    nixfmt
  ];
  settings = {
    formatter = {
      nixfmt = {
        command = "nixfmt";
        includes = [ "*.nix" ];
      };
    };
  };
}
