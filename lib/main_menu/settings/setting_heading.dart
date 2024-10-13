import "package:flutter/material.dart";
import "package:flutter_markdown/flutter_markdown.dart";
import "package:url_launcher/url_launcher_string.dart";

class SettingHeading extends StatelessWidget {
  final String text;

  const SettingHeading(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final TextStyle? titleStyle = textTheme.headlineSmall;
    final TextStyle? labelStyle = textTheme.labelMedium?.copyWith(color: Colors.grey);
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8, top: 16),
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: MarkdownBody(
          data: text,
          onTapLink: (String text, String? href, String title) {
            if (href != null) {
              launchUrlString(href);
            }
          },
          styleSheet: MarkdownStyleSheet(
            h1: titleStyle,
            p: labelStyle,
            a: labelStyle?.copyWith(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
    );
  }
}
