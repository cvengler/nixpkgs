{
  fetchFromGitHub,
  stdenv,
  lib,
  pkgs,
  rustPlatform,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "shadow-simulator";
  version = "3.3.0";
  src = fetchFromGitHub {
    owner = "shadow";
    repo = "shadow";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kgWvrnpWUJ5OWy2+luju8SHDRcveVbdfCKntDgxVj0o=";
  };

  patches = [ ./shadow-nix.patch ];

  nativeBuildInputs = with pkgs; [
    cargo
    cmake
    pkg-config
    python314
    rustPlatform.cargoSetupHook
    rustPlatform.bindgenHook
  ];
  buildInputs = with pkgs; [
    glib
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    src = "${finalAttrs.src}/src";
    hash = "sha256-haoVNmm0uW7LOTSj8/ryWaZ9nmRNA2G5QKv9cOKEjcs=";
  };
  cargoRoot = "src/";

  dontUseCmakeConfigure = true;
  strictDeps = true;
  __structuredAttrs = true;

  buildPhase = ''
    runHook preBuild
    ls -la /
    false
    export PYTHON3_BIN="${pkgs.python314}/bin/python3.14"
    patchShebangs setup
    ./setup build --test --jobs $NIX_BUILD_CORES --prefix $out
    runHook postBuild
  '';

  doCheck = true;
  nativeCheckInputs = with pkgs; [
    bash # bash-example-shadow
    util-linux # lscpu
  ];
  checkInputs = with pkgs; [
    iana-etc # /etc/services
  ];
  checkPhase = ''
    runHook preCheck
    ./setup test --jobs $NIX_BUILD_CORES --verbose
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    ./setup install
    runHook postInstall
  '';
})
