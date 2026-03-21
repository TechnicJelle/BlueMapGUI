import "package:ssg/copy.dart";
import "package:ssg/log.dart";

import "pages/help.dart";
import "pages/home.dart";

Future<void> main(List<String> arguments) async {
  log.info("Starting generation...");

  copyFile("../assets/icon_48.png", "");
  copyFile("../assets/icon_256.png", "");
  copy("styles", "");
  copy("copy", "");
  copy("../.github/readme_assets", "images");

  await createHomePage();
  createHelpPage();

  log.info("Done with generation!");
}
