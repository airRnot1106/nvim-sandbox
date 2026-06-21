{
  inputs = {
    agent-skills = {
      url = "path:./nix/agent-skills";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      agent-skills,
      flake-utils,
      git-hooks,
      neovim-nightly-overlay,
      nixpkgs,
      treefmt-nix,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        neovim-nightly = neovim-nightly-overlay.packages.${system}.neovim;
        nvim = pkgs.writeShellScriptBin "nvim" ''
          export XDG_CONFIG_HOME="${self}"
          exec ${neovim-nightly}/bin/nvim "$@"
        '';
      in
      {
        packages.default = nvim;

        devShells =
          let
            inherit (self.checks.${system}.git-hooks) shellHook enabledPackages;
          in
          {
            default = pkgs.mkShellNoCC {
              inputsFrom = [ agent-skills.devShells.${system}.default ];
              inherit shellHook;
              packages =
                with pkgs;
                [
                  deno
                  lua-language-server
                ]
                ++ enabledPackages;
            };
          };

        formatter =
          let
            treefmtEval = treefmt-nix.lib.evalModule pkgs ./nix/treefmt.nix;
          in
          treefmtEval.config.build.wrapper;

        checks = {
          git-hooks = git-hooks.lib.${system}.run (
            import ./nix/git-hooks.nix {
              inherit self pkgs;
            }
          );
        };
      }
    );
}
