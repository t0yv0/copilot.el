{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-23.11;
  };

  outputs = { self, nixpkgs }: let
    packages = sys: let
      version = self.rev or "dirty";
      pkgs = import nixpkgs { system = sys; };
      epkgs = pkgs.emacsPackagesFor pkgs.emacs29-macport;
      copilot = epkgs.trivialBuild {
        pname = "copilot";
        version = "${version}";
        src = ./.;
        packageRequires = [
          epkgs.dash
          epkgs.s
          epkgs.editorconfig
          epkgs.vterm
          epkgs.jsonrpc
        ];
      };
    in {
      copilot = copilot;
    };
  in {
    packages = builtins.listToAttrs (builtins.map (sys: {
      name = sys;
      value = packages sys;
    }) [
      "x86_64-darwin"
      "aarch64-darwin"
    ]);
  };
}
