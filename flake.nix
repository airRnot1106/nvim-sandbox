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

    ### plugin dependencies ###
    dpp-vim = {
      url = "github:Shougo/dpp.vim";
      flake = false;
    };
    dpp-ext-installer = {
      url = "github:Shougo/dpp-ext-installer";
      flake = false;
    };
    dpp-ext-lazy = {
      url = "github:Shougo/dpp-ext-lazy";
      flake = false;
    };
    dpp-protocol-git = {
      url = "github:Shougo/dpp-protocol-git";
      flake = false;
    };
    denops-vim = {
      url = "github:vim-denops/denops.vim";
      flake = false;
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
      ...
    }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        neovim-nightly = neovim-nightly-overlay.packages.${system}.neovim;

        inherit (inputs)
          dpp-vim
          dpp-ext-installer
          dpp-ext-lazy
          dpp-protocol-git
          denops-vim
          ;

        nvim = pkgs.writeShellScriptBin "nvim" ''
          export XDG_CONFIG_HOME="${self}"
          export DPP_VIM_SRC="${dpp-vim}"
          export DPP_DENOPS_SRC="${denops-vim}"
          export DPP_EXT_INSTALLER_SRC="${dpp-ext-installer}"
          export DPP_EXT_LAZY_SRC="${dpp-ext-lazy}"
          export DPP_PROTOCOL_GIT_SRC="${dpp-protocol-git}"

          # A sentinel to notify dpp's check_files of a flake rebuild
          _sentinel="''${XDG_CACHE_HOME:-$HOME/.cache}/dpp/config-sentinel"
          mkdir -p "$(dirname "$_sentinel")"
          if [ "$(cat "$_sentinel" 2>/dev/null)" != "${self}" ]; then
            printf '%s' "${self}" > "$_sentinel"
          fi

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
            default = pkgs.mkShell {
              inputsFrom = [ agent-skills.devShells.${system}.default ];
              inherit shellHook;
              packages =
                with pkgs;
                [
                  deno
                  lua-language-server
                  tree-sitter
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
