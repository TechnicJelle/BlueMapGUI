import "package:techs_html_bindings/elements.dart";

Footer generateFooter() {
  return Footer(
    children: [
      P(
        children: [
          T("Website last updated on "),
          Time(
            datetime: DateTime.now().toIso8601String(),
            visible: DateTime.now().copyWith(microsecond: 0).toIso8601String().replaceAll("T", " "),
          ),
        ],
      ),
    ],
  );
}
