{
  lib,
  stdenv,
  fetchFromGitHub,
  intltool,
  autoreconfHook,
  pkg-config,
  libqalculate,
  gtk3,
  curl,
  wrapGAppsHook3,
  desktopToDarwinBundle,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qalculate-gtk";
  version = "5.5.1";

  src = fetchFromGitHub {
    owner = "qalculate";
    repo = "qalculate-gtk";
    rev = "v${finalAttrs.version}";
    hash = "sha256-9KXzsMGSdi+nh5x7ehVHLi7Ni+iK+sFpsacj5ByU7M4=";
  };

  hardeningDisable = [ "format" ];

  nativeBuildInputs = [
    intltool
    pkg-config
    autoreconfHook
    wrapGAppsHook3
  ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ desktopToDarwinBundle ];
  buildInputs = [
    libqalculate
    gtk3
    curl
  ];
  enableParallelBuilding = true;

  meta = with lib; {
    description = "Ultimate desktop calculator";
    homepage = "http://qalculate.github.io";
    maintainers = with maintainers; [
      doronbehar
      pentane
      aleksana
    ];
    license = licenses.gpl2Plus;
    mainProgram = "qalculate-gtk";
    platforms = platforms.all;
  };
})
