{
  lib,
  stdenv,
  fetchFromGitHub,
  bun,
  python3,
  nix-update-script,
}:

let
  pname = "openchamber";
  version = "1.13.2";

  src = fetchFromGitHub {
    owner = "openchamber";
    repo = "openchamber";
    rev = "v${version}";
    hash = "sha256-9z2fLqpWxdnOztbc8QPiyeAgBMvJFns9kxSVoMg5MpA=";
  };

  # Dependency builder using Bun fixed-output derivation.
  # The name npmDepsHash is kept so nix-update can automatically update it.
  npmDepsHash = "sha256-Y2kH/js023EyMgoMkFDa9S2tjBJdh+r/YsVNdILQGjg=";
in
stdenv.mkDerivation {
  pname = "${pname}-node-modules";
  inherit version src;

  dontFixup = true;

  impureEnvVars = lib.fetchers.proxyImpureEnvVars;

  nativeBuildInputs = [
    bun
    python3 # For node-gyp native compiles (node-pty, better-sqlite3)
  ];

  buildPhase = ''
    export HOME=$TMPDIR
    export BUN_INSTALL_CACHE_DIR=$(mktemp -d)

    bun install \
      --cpu="*" \
      --frozen-lockfile \
      --ignore-scripts \
      --no-progress \
      --os="*" \
      --linker=isolated
  '';

  installPhase = ''
    mkdir -p $out
    find . -type d -name node_modules -exec cp -R --parents {} $out \;

    # Clean the final output directory recursively:
    # Clean up temporary C++ compilation files and stray Nix files containing store paths
    find $out -type f \( -name "*.o" -o -name "*.d" -o -name "*.mk" -o -name "Makefile" -o -name "config.gypi" -o -name "flake.lock" -o -name "flake.nix" -o -name "default.nix" \) -delete
  '';

  outputHash = npmDepsHash;
  outputHashAlgo = "sha256";
  outputHashMode = "recursive";

  passthru.updateScript = nix-update-script;
}
