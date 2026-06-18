// == Hardcoded BlueMap CLI JAR download URL and hash ==
const blueMapTag = "5.22";
const blueMapCliJarHash =
    "a2289d649f6a83e04cf222abcd3d4f2df4e32e61147015f921c05066f63eefb7"; //SHA256

// == Derived variables ==
final blueMapCliJarUrl = Uri.https(
  "github.com",
  "BlueMap-Minecraft/BlueMap/releases/download/v$blueMapTag/bluemap-$blueMapTag-cli.jar",
);

const String _vDev = "development";
const String version = String.fromEnvironment("version", defaultValue: _vDev);

// == Java Managed ==
// From https://adoptium.net/temurin/releases?version=25&os=any&arch=any
const String javaManagedVersion = "jdk-25.0.3+9";
const String javaManagedLinuxX64Hash =
    "487ad434d8b121ae3902d5ad9cb830cd8e1f75fefad6e2ba80f89d60e3db95d7"; //SHA256
const String javaManagedWindowsX64Hash =
    "a183e7280220ad5f6fe94ecbf025a5f10fc5797a0b18c600ed8f813c8158c530"; //SHA256
