{ nixpkgs ? fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/refs/tags/24.05.tar.gz";
    sha256 = "sha256:1lr1h35prqkd1mkmzriwlpvxcb34kmhc9dnr48gkm8hh089hifmx";
  }
}:

let
  pkgs = (import nixpkgs {});

  # poetry2nix is maintained on GitHub. The default version in the nixpkgs repository
  # crashes with an error telling us to get it from GitHub instead.
  poetry2nix-src = pkgs.fetchFromGitHub {
    owner = "nix-community";
    repo = "poetry2nix";
    rev = "2024.7.161740";
    sha256 = "sha256-UU/lVTHFx0GpEkihoLJrMuM9DcuhZmNe3db45vshSyI=";
  };

  poetry2nix = import poetry2nix-src { inherit pkgs; };

  pythonEnv = poetry2nix.mkPoetryEnv {
    projectDir = ./.;
    overrides = poetry2nix.overrides.withDefaults (final: prev: {
      zipfile2 = [ "setuptools" ];
      jsonschema2md = [ "poetry-core" ];
      okonomiyaki = [ "setuptools" ];
      simplesat = [ "setuptools" ];
      fusesoc = [ "setuptools" ];
    });
  };
in

pythonEnv.env.overrideAttrs (oldAttrs: {
  buildInputs = [
    pkgs.poetry
  ];

  shellHook = ''
    echo ${pythonEnv}
  '';
})
