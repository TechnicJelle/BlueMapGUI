import "dart:io";

import "package:path/path.dart" as p;
import "package:techs_html_bindings/elements.dart";

late final Directory buildDir;

void main(List<String> arguments) {
  buildDir = Directory("build")..createSync();
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
        Meta.httpEquiv(httpEquiv: "refresh", content: "0;url=$redirectTo"),
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
        Link.icon(type: "image/png", sizes: "48x48", href: icon(48)),
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
  final String filename = "icon_$size.png";
  final File iconFile = File("../assets/$filename");
  if (!iconFile.existsSync()) {
    throw FileSystemException("File not found!", iconFile.path);
  }
  iconFile.copySync(p.join(buildDir.path, filename));
  return filename;
}
