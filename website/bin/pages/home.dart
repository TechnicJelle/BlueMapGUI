import "dart:io";

import "package:path/path.dart" as p;
import "package:ssg/components/footer.dart";
import "package:ssg/components/head.dart";
import "package:ssg/components/header.dart";
import "package:ssg/constants.dart";
import "package:techs_html_bindings/elements.dart";

// I am being evil and including a file from a different project's lib.
// That cannot be transformed into a relative import.
// ignore: avoid_relative_lib_imports
import "../../../lib/update_checker.dart";

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
          _two(
            [
              H1.text("BlueMap GUI"),
              P(
                classes: ["tagline"],
                children: [
                  T("See your worlds in full 3D with "),
                  A.text("BlueMap", href: "https://bluemap.bluecolored.de/"),
                  T(" with the ease of simple buttons!"),
                ],
              ),
              P.text("With this desktop program, you can render your Minecraft worlds and view them in your browser."),
              P(
                id: "downloads",
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
              Br(),
              P(
                classes: ["download-extras"],
                children: [
                  A(
                    href: "$repo/releases",
                    children: [T("Changelog ›")],
                  ),
                  A(
                    href: "$repo/actions/workflows/build.yml",
                    children: [T("Preview Builds ›")],
                  ),
                ],
              ),
            ],
            Picture.darkLight(
              darkSrc: "images/dark/control_panel.png",
              lightSrc: "images/light/control_panel.png",
              alt: "Screenshot",
            ),
          ),
          _two(
            [
              H2.text("Powered by BlueMap", autoLink: false),
              P.text(
                "BlueMap GUI is a wrapper around the BlueMap CLI tool. BlueMap itself is mainly meant as a mod/plugin for servers, but its CLI can render any world at all; even worlds that aren't part of a server, like single-player worlds, or worlds that you downloaded. BlueMap GUI makes it easy to use for people who are not familiar with the command line, don't have a server, or just want a more user-friendly experience.",
              ),
            ],
            Picture.darkLight(
              darkSrc: "images/dark/bluemap.png",
              lightSrc: "images/light/bluemap.png",
              alt: "Screenshot",
            ),
          ),
          _two(
            [
              H2.text("Simple Configuration Editor", autoLink: false),
              P.text(
                "Meticulously crafted to show only the settings you need, right where you want them, with detailed explanations of what they do.",
              ),
            ],
            Picture.darkLight(
              darkSrc: "images/dark/config_map_overworld.png",
              lightSrc: "images/light/config_map_overworld.png",
              alt: "Screenshot",
            ),
          ),
          _two(
            [
              H2.text("Advanced Configuration Editor", autoLink: false),
              P.text(
                "If you find that the simple configuration editor lacks something, or you just want to explore the \"Hidden\" options, then you can always switch to the Advanced Configuration Editor. This view shows the actual \"raw\" configuration files of Bluemap.",
              ),
            ],
            Picture.darkLight(
              darkSrc: "images/dark/config_map_overworld_advanced.png",
              lightSrc: "images/light/config_map_overworld_advanced.png",
              alt: "Screenshot",
            ),
          ),
          _two(
            [
              H2.text("Manage Multiple Projects", autoLink: false),
              P.text(
                "You can manage multiple worlds, across different Minecraft versions and even modpacks by making Projects.",
              ),
            ],
            Picture.darkLight(
              darkSrc: "images/dark/projects_list.png",
              lightSrc: "images/light/projects_list.png",
              alt: "Screenshot",
            ),
          ),
          P(
            classes: ["final-download"],
            children: [
              Span.text("Are you convinced, yet?"),
              Br(),
              A.text("Download", href: "#downloads"),
            ],
          ),
        ],
      ),
      footer: generateFooter(),
    ),
  ).build();

  File(p.join(dirBuild.path, "index.html")).writeAsStringSync(html);
}

Section _two(List<Element> aside, Picture picture) {
  return Section(
    classes: ["two"],
    children: [
      Div(children: aside),
      picture,
    ],
  );
}

String url(String latestVersion, {required String platform}) =>
    "$repo/releases/download/v$latestVersion/BlueMapGUI_v${latestVersion}_$platform.zip";
