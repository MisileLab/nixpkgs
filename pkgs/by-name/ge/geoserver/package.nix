{
  lib,
  callPackage,
  fetchurl,
  makeWrapper,
  nixosTests,
  stdenv,
  jre,
  unzip,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "geoserver";
  version = "2.27.0";

  src = fetchurl {
    url = "mirror://sourceforge/geoserver/GeoServer/${finalAttrs.version}/geoserver-${finalAttrs.version}-bin.zip";
    hash = "sha256-bhL+u+BoKgW2cwOXEzaq0h07dKFz9u9WB2jW8nAF0vI=";
  };

  sourceRoot = "source";

  unpackPhase = ''
    runHook preUnpack
    unzip $src -d "$sourceRoot"
    runHook postUnpack
  '';

  patches = [
    # set GEOSERVER_DATA_DIR to current working directory if not provided
    ./data-dir.patch
  ];

  nativeBuildInputs = [
    unzip
    makeWrapper
  ];

  installPhase =
    let
      inputs = finalAttrs.buildInputs or [ ];
      ldLibraryPathEnvName =
        if stdenv.hostPlatform.isDarwin then "DYLD_LIBRARY_PATH" else "LD_LIBRARY_PATH";
    in
    ''
      runHook preInstall
      mkdir -p $out/share/geoserver
      cp -r . $out/share/geoserver
      rm -fr $out/share/geoserver/bin/*.bat

      makeWrapper $out/share/geoserver/bin/startup.sh $out/bin/geoserver-startup \
        --prefix PATH : "${lib.makeBinPath inputs}" \
        --prefix ${ldLibraryPathEnvName} : "${lib.makeLibraryPath inputs}" \
        --set JAVA_HOME "${jre}" \
        --set GEOSERVER_HOME "$out/share/geoserver"
      makeWrapper $out/share/geoserver/bin/shutdown.sh $out/bin/geoserver-shutdown \
        --prefix PATH : "${lib.makeBinPath inputs}" \
        --prefix ${ldLibraryPathEnvName} : "${lib.makeLibraryPath inputs}" \
        --set JAVA_HOME "${jre}" \
        --set GEOSERVER_HOME "$out/share/geoserver"
      runHook postInstall
    '';

  passthru =
    let
      geoserver = finalAttrs.finalPackage;
      extensions = lib.attrsets.filterAttrs (n: v: lib.isDerivation v) (callPackage ./extensions.nix { });
    in
    {
      withExtensions =
        selector:
        let
          selectedExtensions = selector extensions;
        in
        geoserver.overrideAttrs (
          finalAttrs: previousAttrs: {
            pname = previousAttrs.pname + "-with-extensions";
            buildInputs = lib.lists.unique (
              (previousAttrs.buildInputs or [ ]) ++ lib.lists.concatMap (drv: drv.buildInputs) selectedExtensions
            );
            postInstall =
              (previousAttrs.postInstall or "")
              + ''
                for extension in ${builtins.toString selectedExtensions} ; do
                  cp -r $extension/* $out
                  # Some files are the same for all/several extensions. We allow overwriting them again.
                  chmod -R +w $out
                done
              '';
          }
        );
      tests.geoserver = nixosTests.geoserver;
      updateScript = ./update.sh;
    };

  meta = with lib; {
    description = "Open source server for sharing geospatial data";
    homepage = "https://geoserver.org/";
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    license = licenses.gpl2Plus;
    teams = [ teams.geospatial ];
    platforms = platforms.all;
  };
})
