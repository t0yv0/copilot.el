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
          pkgs.patchelf
          epkgs.dash
          epkgs.s
          epkgs.editorconfig
          epkgs.vterm
          epkgs.jsonrpc
        ];
        postInstall = ''
           mkdir -p $out/share/emacs/site-lisp/
           cp -r $src/dist $out/share/emacs/site-lisp/
        '';
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
