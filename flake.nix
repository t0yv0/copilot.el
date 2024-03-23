{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixpkgs-23.11-darwin;
  };

  outputs = { self, nixpkgs }: let
    packages = sys: let
      version = self.rev or "dirty";
      pkgs = import nixpkgs { system = sys; };
      epkgs = pkgs.emacsPackagesFor pkgs.emacs29-macport;

      deps = import ./deps/default.nix {
        pkgs = pkgs;
        nodejs = pkgs.nodejs;
      };

      copilot-node-server = builtins.getAttr "copilot-node-server-1.14.0" deps;

      copilot = epkgs.trivialBuild {
        pname = "copilot";
        version = "${version}";
        src = ./.;
        packageRequires = [
          epkgs.f
          epkgs.editorconfig
          epkgs.vterm
        ];
        postPatch = ''
          substituteInPlace copilot.el \
            --replace '(locate-user-emacs-file (f-join ".cache" "copilot"))' \
                "\"$out/dist/node_modules/copilot-node-server\""
          substituteInPlace copilot.el \
            --replace '(f-join copilot-install-dir "lib" "node_modules" "copilot-node-server" "package.json")' \
                '(f-join copilot-install-dir "package.json")'
        '';
        postInstall = ''
          mkdir -p "$out/dist"
          cp -r ${copilot-node-server}/lib/* "$out/dist/"
        '';
      };
    in {
      default = copilot;
      copilot = copilot;
      copilot-node-server = copilot-node-server;
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
