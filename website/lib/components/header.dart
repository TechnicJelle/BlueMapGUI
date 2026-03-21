import "package:techs_html_bindings/elements.dart";

Header generateHeader({
  String pathToHome = "./",
  String pathToHelp = "help",
}) {
  return Header(
    children: [
      Nav(
        children: [
          UnorderedList(
            items: [
              ListItem(
                children: [
                  A(
                    href: pathToHome,
                    children: [
                      Image(
                        src: "${pathToHome}icon_48.png",
                        alt: "icon",
                        width: 48,
                        height: 48,
                      ),
                      T("BlueMap GUI"),
                    ],
                  ),
                ],
              ),
              ListItem(
                children: [
                  A(href: pathToHelp, children: [T("Help")]),
                ],
              ),
              ListItem(
                children: [
                  A(
                    href: "https://github.com/TechnicJelle/BlueMapGUI",
                    children: [T("Source Code")],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
