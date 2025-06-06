{
  lib,
  stdenv,
  buildNpmPackage,
  fetchFromGitHub,
  systemdMinimal,
  nixosTests,
  nix-update-script,
  withSystemd ? lib.meta.availableOn stdenv.hostPlatform systemdMinimal,
}:

buildNpmPackage rec {
  pname = "zigbee2mqtt";
  version = "1.42.0";

  src = fetchFromGitHub {
    owner = "Koenkk";
    repo = "zigbee2mqtt";
    rev = version;
    hash = "sha256-/7mZrf3FyIliCzsy6yzVRJYMy4bViphYi81UY43iO98=";
  };

  npmDepsHash = "sha256-heqTYLC+TQPQ2dc5MrVdvJeNqrygC4tUgkLcfKvlYvE=";

  buildInputs = lib.optionals withSystemd [
    systemdMinimal
  ];

  npmFlags = lib.optionals (!withSystemd) [ "--omit=optional" ];

  passthru.tests.zigbee2mqtt = nixosTests.zigbee2mqtt_1;
  passthru.updateScript = nix-update-script { };

  meta = {
    changelog = "https://github.com/Koenkk/zigbee2mqtt/releases/tag/${version}";
    description = "Zigbee to MQTT bridge using zigbee-shepherd";
    homepage = "https://github.com/Koenkk/zigbee2mqtt";
    license = lib.licenses.gpl3;
    longDescription = ''
      Allows you to use your Zigbee devices without the vendor's bridge or gateway.

      It bridges events and allows you to control your Zigbee devices via MQTT.
      In this way you can integrate your Zigbee devices with whatever smart home infrastructure you are using.
    '';
    maintainers = with lib.maintainers; [
      sweber
      hexa
    ];
    mainProgram = "zigbee2mqtt";
  };
}
