{
  autoreconfHook,
  coreutils,
  diffutils,
  fetchFromGitHub,
  gzip,
  lib,
  makeWrapper,
  ncurses,
  nix-update-script,
  stdenv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mg-troglobit";
  version = "4.6";

  src = fetchFromGitHub {
    owner = "troglobit";
    repo = "mg";
    tag = "v${finalAttrs.version}";
    hash = "sha256-uRuCDzIDO/+GhEufPP1TGhhbZ29PJ/KrZGGuIfc7B0Q=";
  };

  nativeBuildInputs = [
    autoreconfHook
    makeWrapper
  ];
  buildInputs = [ ncurses ];
  enableParallelBuilding = true;

  __structuredAttrs = true;
  strictDeps = true;

  postPatch = ''
    substituteInPlace src/buffer.c \
      --replace-fail '"/usr/bin/diff"' '"${lib.getExe' diffutils "diff"}"'
  '';

  postInstall = ''
    wrapProgram $out/bin/mg \
      --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          gzip
        ]
      }
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Micro (GNU) Emacs-like text editor";
    homepage = "https://github.com/troglobit/mg";
    maintainers = with lib.maintainers; [ cve ];
    license = lib.licenses.publicDomain;
    mainProgram = "mg";
    platforms = lib.platforms.all;
  };
})
