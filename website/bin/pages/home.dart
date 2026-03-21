import "dart:io";

import "package:path/path.dart" as p;
import "package:ssg/components/footer.dart";
import "package:ssg/components/head.dart";
import "package:ssg/components/header.dart";
import "package:ssg/constants.dart";
import "package:techs_html_bindings/elements.dart";
import "package:techs_html_bindings/markdown.dart";

// I am being evil and including a file from a different project's lib.
// That cannot be transformed into a relative import.
// ignore: avoid_relative_lib_imports
import "../../../lib/update_checker.dart";

const String repo = "https://github.com/TechnicJelle/BlueMapGUI";

Future<void> createHomePage() async {
  final updateChecker = UpdateChecker(
    author: "TechnicJelle",
    repoName: "BlueMapGUI",
    currentVersion: "",
  );
  final String latestVersion = await updateChecker.getLatestVersion();

  final String html = HTML(
    lang: "en",
    head: generateHead(
      extraStyles: [
        Style(css: File("styles/home.css").readAsStringSync()),
      ],
    ),
    body: Body(
      header: generateHeader(),
      main: Main(
        children: [
          H1(children: [T("BlueMap GUI")]),
          P(
            classes: ["tagline"],
            children: [
              T("See your worlds in full 3D with "),
              A(href: "https://bluemap.bluecolored.de/", children: [T("BlueMap")]),
              T(" with the ease of simple buttons!"),
            ],
          ),
          P(
            classes: ["description"],
            children: [
              T(
                "This program is a GUI wrapper around the BlueMap CLI tool, which makes it easier to use for people who are not familiar with the command line, don't have a server, or just want a more user-friendly experience.",
              ),
            ],
          ),
          Picture.darkLight(
            classes: ["hero"],
            darkSrc: "images/dark/control_panel.png",
            lightSrc: "images/light/control_panel.png",
            alt: "Screenshot",
          ),
          H2(children: [T("Download")], autoLink: false),
          Div(
            classes: ["download-buttons"],
            children: [
              A(
                href: url(latestVersion, platform: "Windows_x64"),
                children: [
                  Image(
                    src: "icons/windows.svg",
                    alt: "Windows icon",
                    height: 32,
                    width: 36,
                  ),
                  T("Windows"),
                ],
              ),
              A(
                href: url(latestVersion, platform: "Linux_x64"),
                children: [
                  Image(
                    src: "icons/linux.svg",
                    alt: "Linux icon",
                    height: 32,
                    width: 27,
                  ),
                  T("Linux"),
                ],
              ),
            ],
          ),
          P(
            classes: ["download-previews"],
            children: [
              A(
                href: "$repo/actions/workflows/build.yml",
                children: [T("Preview Builds")],
              ),
            ],
          ),
          P(
            classes: ["download-changelog"],
            children: [
              A(
                href: "$repo/releases",
                children: [T("Changelog")],
              ),
            ],
          ),
          H2(children: [T("Open Source")], autoLink: false),
          P(children: [T("BlueMap GUI is open source!")]),
          A(
            href: "https://github.com/TechnicJelle/BlueMapGUI",
            classes: ["star"],
            children: [T("If you like the software, please give me a star on GitHub")],
          ),
          ...markdown(
            "If you _really_ like it, consider [sponsoring me on GitHub](https://github.com/sponsors/TechnicJelle) or [buying me a Ko-fi](https://ko-fi.com/technicjelle)!",
          ),
        ],
      ),
      footer: generateFooter(),
    ),
  ).build();

  File(p.join(dirBuild.path, "index.html")).writeAsStringSync(html);
}

String url(String latestVersion, {required String platform}) =>
    "$repo/releases/download/v$latestVersion/BlueMapGUI_v${latestVersion}_$platform.zip";
