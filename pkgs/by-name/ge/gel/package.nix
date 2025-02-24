{
  stdenv,
  lib,
  patchelf,
  fetchFromGitHub,
  rustPlatform,
  makeBinaryWrapper,
  pkg-config,
  curl,
  openssl,
  xz,
  replaceVars,
  # for passthru.tests:
  gel,
  testers,
}:
rustPlatform.buildRustPackage rec {
  pname = "gel";
  version = "7.0.2";

  src = fetchFromGitHub {
    owner = "geldata";
    repo = "gel-cli";
    tag = "v${version}";
    hash = "sha256-SJiwvsLTiMlRwwZlDnU7Jxe0FnThmu8jXCbeNL+2uwk=";
    fetchSubmodules = true;
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-YUsPi3enOI7/Uh9Cb0UCuOKFfH03RAq4Cc5zuRQ8CUw=";
  };

  nativeBuildInputs = [
    makeBinaryWrapper
    pkg-config
  ];

  buildInputs =
    [
      curl
    ]
    ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
      openssl
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      xz
    ];

  checkFeatures = [ ];

  patches = [
    (replaceVars ./0001-dynamically-patchelf-binaries.patch {
      inherit patchelf;
      dynamicLinker = stdenv.cc.bintools.dynamicLinker;
    })
  ];

  env = {
    OPENSSL_NO_VENDOR = true;
  };

  doCheck = false;

  passthru.tests.version = testers.testVersion {
    package = gel;
    command = "edgedb --version";
  };

  meta = {
    description = "Gel cli";
    homepage = "https://www.edgedb.com/docs/cli/index";
    license = with lib.licenses; [
      asl20
      # or
      mit
    ];
    maintainers = with lib.maintainers; [
      ahirner
      kirillrdy
    ];
    mainProgram = "edgedb";
  };
}
