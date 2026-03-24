// == Hardcoded BlueMap CLI JAR download URL and hash ==
const blueMapTag = "5.17";
const blueMapCliJarHash =
    "49a1d324af7cb85c1153bbe24d086fd5e93ef6ffdb9ab7276b281ade137da55f"; //SHA256

// == Derived variables ==
final blueMapCliJarUrl = Uri.https(
  "github.com",
  "BlueMap-Minecraft/BlueMap/releases/download/v$blueMapTag/bluemap-$blueMapTag-cli.jar",
);

const String vDev = "development";
const String version = String.fromEnvironment("version", defaultValue: vDev);

// == Java Bundle ==
const String javaBundleVersion = "jdk-25.0.2+10";
const String javaBundleLinuxX64Hash =
    "d6c89e08f42be94cd55eab20190958a35b993625018a3ac59cb3d16d8445cf98"; //SHA256
const String javaBundleWindowsX64Hash =
    "1919e7e1603bc5937187139db2d65824f8d95ef42d0423ae9f9f1d9eb97842f6"; //SHA256
