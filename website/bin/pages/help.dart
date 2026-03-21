import "dart:io";

import "package:path/path.dart" as p;
import "package:ssg/components/footer.dart";
import "package:ssg/components/head.dart";
import "package:ssg/components/header.dart";
import "package:ssg/constants.dart";
import "package:techs_html_bindings/elements.dart";
import "package:techs_html_bindings/markdown.dart";

void createHelpPage() {
  final String html = HTML(
    lang: "en",
    head: generateHead(
      pageTitle: "Help",
      pageDescription: "Help for BlueMap GUI; a GUI wrapper around the BlueMap CLI",
      relativeToRoot: "../",
      extraStyles: [
        Style(css: File("styles/help.css").readAsStringSync()),
      ],
    ),
    body: Body(
      header: generateHeader(pathToHome: "../", pathToHelp: "."),
      main: Main(
        children: [
          _toc(),
          Section(
            classes: ["guide"],
            children: markdown(File("../USAGE.md").readAsStringSync()),
          ),
        ],
      ),
      footer: generateFooter(),
    ),
  ).build();

  final dirHelp = Directory(p.join(dirBuild.path, "help"))..createSync();
  File(p.join(dirHelp.path, "index.html")).writeAsStringSync(html);
}

Aside _toc() {
  return Aside(
    children: [
      Nav(
        children: [
          H2(id: "toc", children: [T("Table of Contents")]),
          OrderedList(
            items: [
              _li("#1-setting-up-java", "Setting up Java"),
              _li("#2-creating-a-project", "Creating a project"),
              ListItem(
                children: [
                  _a("#3-setting-up-bluemap", "Setting up BlueMap"),
                  OrderedList(
                    type: .lowercaseLetters,
                    items: [
                      _li(
                        "#3a-accepting-the-download",
                        "Accepting the download",
                      ),
                      _li("#3b-configuring-your-maps", "Configuring your maps"),
                      _li(
                        "#3c-optional-setting-up-resourcepacks--datapacks",
                        "Resource-packs & Data-packs",
                      ),
                      _li("#3d-optional-setting-up-mods", "Mods"),
                      _li("#3e-optional-minecraft-version", "Minecraft Version"),
                    ],
                  ),
                ],
              ),
              _li("#4-starting-bluemap", "Starting BlueMap"),
            ],
          ),
          _a("#support", "Support"),
        ],
      ),
    ],
  );
}

A _a(String href, String label) {
  return A(href: href, children: [T(label)]);
}

ListItem _li(String href, String label) {
  return ListItem(children: [_a(href, label)]);
}
