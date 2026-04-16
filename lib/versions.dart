// == Hardcoded BlueMap CLI JAR download URL and hash ==
const blueMapTag = "5.20";
const blueMapCliJarHash =
    "b710cdfef1b8dbd0474f4f53ad207cb9086607c8abae6bef3975f8397dce482d"; //SHA256

// == Derived variables ==
final blueMapCliJarUrl = Uri.https(
  "github.com",
  "BlueMap-Minecraft/BlueMap/releases/download/v$blueMapTag/bluemap-$blueMapTag-cli.jar",
);

const String _vDev = "development";
const String version = String.fromEnvironment("version", defaultValue: _vDev);

// == Java Managed ==
const String javaManagedVersion = "jdk-25.0.2+10";
const String javaManagedLinuxX64Hash =
    "d6c89e08f42be94cd55eab20190958a35b993625018a3ac59cb3d16d8445cf98"; //SHA256
const String javaManagedWindowsX64Hash =
    "1919e7e1603bc5937187139db2d65824f8d95ef42d0423ae9f9f1d9eb97842f6"; //SHA256
