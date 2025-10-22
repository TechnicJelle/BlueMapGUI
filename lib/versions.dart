// == Hardcoded BlueMap CLI JAR download URL and hash ==
const blueMapTag = "5.12";
const blueMapCliJarHash =
    "93eb5222580e8fba3b6873dd2735d25b5cf1c76a59ebb4c1dda27816fed4d293"; //SHA256

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
