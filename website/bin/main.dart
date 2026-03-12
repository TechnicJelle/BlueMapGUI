import "dart:io";

import "package:path/path.dart" as p;
import "package:techs_html_bindings/elements.dart";

void main(List<String> arguments) {
  final Directory buildDir = Directory("build")..createSync();
  final File index = File(p.join(buildDir.path, "index.html"));

  const String title = "BlueMap GUI";
  const String description =
      "A GUI wrapper around the BlueMap CLI, mainly to make using BlueMap easier to use on single player worlds.";

  const String redirectTo = "https://github.com/TechnicJelle/BlueMapGUI#readme";

  final String html = HTML(
    lang: "en",
    head: Head(
      title: title,
      metas: [
        Meta.httpEquiv(httpEquiv: "refresh", content: "5;url=$redirectTo"),
        Meta.name(name: "og:title", content: title),
        Meta.name(name: "description", content: description),
        Meta.name(name: "og:description", content: description),
        Meta.name(name: "theme-color", content: "#001FF1"),
        Meta.name(
          name: "og:image",
          content: "https://technicjelle.com/BlueMapGUI/${icon(256)}",
        ),
        Meta.httpEquiv(httpEquiv: "X-Clacks-Overhead", content: "GNU Terry Pratchett"),
      ],
      links: [
        Link.icon(type: "image/png", sizes: "48x48", href: "/${icon(48)}"),
      ],
      styles: [
        Style(
          css: """
:root {
  color-scheme: light dark;
}

html {
  font-family: sans-serif;
  
  /* Horizonal Centering */
  text-align: center;
  
  /* Vertical Centering */
  height: 100%;
  align-content: center;
}
""",
        ),
      ],
    ),
    body: Body(
      header: Header(
        children: [
          H1(
            autoID: false,
            children: [
              T.multiline([
                T("This page is still WIP."),
                T("You are being redirected to the current homepage."),
              ]),
            ],
          ),
          A(href: redirectTo, children: [T("Click here if you are not redirected.")]),
        ],
      ),
      main: Main(children: []),
      footer: Footer(children: []),
    ),
  ).build();
  index.writeAsStringSync(html);
}

String icon(int size) {
  final File iconFile = File("../assets/icon_$size.png");
  if (!iconFile.existsSync()) {
    throw FileSystemException("File not found!", iconFile.path);
  }
  final File newFile = File("build/icon_$size.png");
  iconFile.copySync(newFile.path);
  return p.basename(newFile.path);
}
