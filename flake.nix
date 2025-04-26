{
  description = "Example Python project tested with Nix flakes";

  inputs = {
    nixpkgs.url       = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url   = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        python = pkgs.python311;           # pin the interpreter once
      in
      {
        ### Dev shell ────────────────
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            python
            python.pkgs.pip
            python.pkgs.setuptools
            python.pkgs.pytest
            python.pkgs.black
          ];
        };

        ### CI checks ────────────────
        # `nix flake check` will run this automatically.
        checks.pytests = pkgs.runCommand "pytest" { } ''
          export HOME=$TMPDIR        # pytest likes a writable HOME
          ${python}/bin/python -m pytest -q test_sysexit.py
          touch $out                 # produce a dummy artifact
        '';
      });
}
