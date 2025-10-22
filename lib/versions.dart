// == Hardcoded BlueMap CLI JAR download URL and hash ==
const blueMapTag = "5.13";
const blueMapCliJarHash =
    "3439ec94d27707a0a3c6beaa7a6f71457ef575d1cfd35e1c1b29c965d8850e91"; //SHA256

// == Derived variables ==
final blueMapCliJarUrl = Uri.https(
  "github.com",
  "BlueMap-Minecraft/BlueMap/releases/download/v$blueMapTag/bluemap-$blueMapTag-cli.jar",
);

const String vDev = "development";
const String version = String.fromEnvironment("version", defaultValue: vDev);

// == Java Bundle ==
const String javaBundleVersion = "jdk-21.0.8+9";
const String javaBundleLinuxX64Hash =
    "968c283e104059dae86ea1d670672a80170f27a39529d815843ec9c1f0fa2a03"; //SHA256
const String javaBundleWindowsX64Hash =
    "238d74ec4ec9422d416fa98805ba375eecd8bc8f971bd0c61a21051a4fe42db8"; //SHA256
