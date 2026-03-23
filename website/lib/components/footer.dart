import "package:techs_html_bindings/elements.dart";

import "../constants.dart";

Footer generateFooter() {
  return Footer(
    children: [
      Span(
        children: [
          A.newTab(
            href: repo,
            children: [T("⭐ Star on GitHub")],
          ),
          A.newTab(
            href: "https://github.com/sponsors/TechnicJelle",
            children: [T("Sponsor")],
          ),
          A.newTab(
            href: "https://ko-fi.com/technicjelle",
            children: [T("Support on Ko-fi")],
          ),
        ],
      ),
      Span(
        children: [
          T("Website last updated on "),
          Time(
            datetime: DateTime.now().toIso8601String(),
            visible: DateTime.now()
                .copyWith(microsecond: 0)
                .toIso8601String()
                .replaceAll("T", " "),
          ),
        ],
      ),
    ],
  );
}
