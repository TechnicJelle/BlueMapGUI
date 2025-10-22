import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";

class SettingHeading extends StatelessWidget {
  final String title;
  late final List<TextSpan> textSpans = [];

  SettingHeading(
    BuildContext context,
    this.title,
    List<SettingsBodyBase> text, {
    super.key,
  }) {
    for (final SettingsBodyBase body in text) {
      textSpans.add(body.build(context));
    }
  }

  SettingHeading.text(BuildContext context, this.title, String text, {super.key}) {
    textSpans.add(SettingsBodyText(text).build(context));
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final TextStyle? titleStyle = textTheme.headlineSmall;
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8, top: 16),
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(text: "$title\n", style: titleStyle),
              const WidgetSpan(child: SizedBox(height: 22)),
              ...textSpans,
            ],
          ),
        ),
      ),
    );
  }
}

abstract class SettingsBodyBase {
  const SettingsBodyBase();

  TextTheme getTextTheme(BuildContext context) => Theme.of(context).textTheme;

  TextStyle? getLabelStyle(BuildContext context) =>
      getTextTheme(context).labelMedium?.copyWith(color: Colors.grey);

  TextStyle? getLinkStyle(BuildContext context) {
    final TextStyle? labelStyle = getLabelStyle(context);
    return labelStyle?.copyWith(
      color: Colors.blue,
      decoration: TextDecoration.underline,
    );
  }

  TextSpan build(BuildContext context);
}

class SettingsBodyText extends SettingsBodyBase {
  final String text;

  const SettingsBodyText(this.text);

  @override
  TextSpan build(BuildContext context) {
    return TextSpan(text: text, style: getLabelStyle(context));
  }
}

class SettingsBodyLink extends SettingsBodyBase {
  final String text;
  final String url;

  const SettingsBodyLink(this.text, this.url);

  @override
  TextSpan build(BuildContext context) {
    return TextSpan(
      text: text,
      style: getLinkStyle(context),
      mouseCursor: SystemMouseCursors.click,
      recognizer: TapGestureRecognizer()..onTap = () => launchUrl(Uri.parse(url)),
    );
  }
}
