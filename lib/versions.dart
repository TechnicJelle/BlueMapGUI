// == Hardcoded BlueMap CLI JAR download URL and hash ==
const blueMapTag = "5.26";
const blueMapCliJarHash =
    "3946686e4005ad17ed2b7ae334dbcc280722310f73de9be880d0dd305d885658"; //SHA256

// == Derived variables ==
final blueMapCliJarUrl = Uri.https(
  "github.com",
  "BlueMap-Minecraft/BlueMap/releases/download/v$blueMapTag/bluemap-$blueMapTag-cli.jar",
);

const String _vDev = "development";
const String version = String.fromEnvironment("version", defaultValue: _vDev);

// == Java Managed ==
// From https://adoptium.net/temurin/releases?version=25&os=any&arch=any
const String javaManagedVersion = "jdk-25.0.4.1+1";
const String javaManagedLinuxX64Hash =
    "1731a34baadec5479258ea0202e4d5d865d2efeee60cb0c7d7eb056fe96ca219"; //SHA256
const String javaManagedWindowsX64Hash =
    "4c95451cea98556def2c54f7782933f52a26d4a36bd85e1d59f0364464828b07"; //SHA256
