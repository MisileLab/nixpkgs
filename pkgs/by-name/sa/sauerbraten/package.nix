{
  lib,
  stdenv,
  fetchzip,

  # nativeBuildInputs
  makeWrapper,
  copyDesktopItems,

  # buildInputs
  libGL,
  SDL2,
  SDL2_image,
  SDL2_mixer,
  xorg,
  zlib,

  makeDesktopItem,
}:

stdenv.mkDerivation rec {
  pname = "sauerbraten";
  version = "2020-12-29";

  src = fetchzip {
    url = "mirror://sourceforge/sauerbraten/sauerbraten_${
      builtins.replaceStrings [ "-" ] [ "_" ] version
    }_linux.tar.bz2";
    hash = "sha256-os3SmonqHRw1+5dIRVt7EeXfnSq298GiyKpusS1K3rM=";
  };

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = [
    libGL
    SDL2
    SDL2_image
    SDL2_mixer
    xorg.libX11
    zlib
  ];

  sourceRoot = "${src.name}/src";

  enableParallelBuilding = true;

  desktopItems = [
    (makeDesktopItem {
      name = "sauerbraten";
      exec = "sauerbraten_client %u";
      icon = "sauerbraten";
      desktopName = "Sauerbraten";
      comment = "FPS that uses an improved version of the Cube engine";
      categories = [
        "Application"
        "Game"
        "ActionGame"
      ];
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/icon/ $out/share/sauerbraten $out/share/doc/sauerbraten
    cp -r "../docs/"* $out/share/doc/sauerbraten/
    cp sauer_client sauer_server $out/share/sauerbraten/
    cp -r ../packages ../data $out/share/sauerbraten/
    ln -s $out/share/sauerbraten/data/cube.png $out/share/icon/sauerbraten.png

    makeWrapper $out/share/sauerbraten/sauer_server $out/bin/sauerbraten_server \
      --chdir "$out/share/sauerbraten"
    makeWrapper $out/share/sauerbraten/sauer_client $out/bin/sauerbraten_client \
      --chdir "$out/share/sauerbraten" \
      --add-flags "-q\''${HOME}/.config/sauerbraten"

    runHook postInstall
  '';

  meta = {
    description = "Free multiplayer & singleplayer first person shooter, the successor of the Cube FPS";
    homepage = "http://sauerbraten.org";
    maintainers = with lib.maintainers; [
      raskin
      ajs124
    ];
    mainProgram = "sauerbraten_client";
    hydraPlatforms =
      # raskin: tested amd64-linux;
      # not setting platforms because it is 0.5+ GiB of game data
      [ ];
    license = "freeware"; # as an aggregate - data files have different licenses code is under zlib license
    platforms = lib.platforms.linux;
  };
}
