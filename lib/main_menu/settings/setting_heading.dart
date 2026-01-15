import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";

import "../../utils.dart";

class SettingHeading extends StatelessWidget {
  final String title;
  late final List<TextSpan> textSpans = [];
  final EdgeInsets padding;

  SettingHeading(
    BuildContext context,
    this.title,
    List<SettingsBodyBase> text, {
    this.padding = const EdgeInsets.only(left: 16, bottom: 8, top: 16),
    super.key,
  }) {
    for (final SettingsBodyBase body in text) {
      textSpans.add(body.build(context));
    }
  }

  SettingHeading.text(
    BuildContext context,
    this.title,
    String text, {
    this.padding = const EdgeInsets.only(left: 16, bottom: 8, top: 16),
    super.key,
  }) {
    textSpans.add(SettingsBodyText(text).build(context));
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final TextStyle? titleStyle = textTheme.headlineSmall;
    return Padding(
      padding: padding,
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

  TextStyle? getCodeStyle(BuildContext context) =>
      getLabelStyle(context)?.copyWith(fontFamily: pixelCode.fontFamily);

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

class SettingsBodyCode extends SettingsBodyBase {
  final String text;

  const SettingsBodyCode(this.text);

  @override
  TextSpan build(BuildContext context) {
    return TextSpan(text: text, style: getCodeStyle(context));
  }
}

class SettingsBodyLink extends SettingsBodyBase {
  final String text;
  final String url;

  const SettingsBodyLink(this.text, this.url);

  @override
  TextSpan build(BuildContext context) {
    return TextSpan(
      children: [
        WidgetSpan(
          child: Tooltip(
            richMessage: _LinkSpan(url, url, getLinkStyle(context)),
            child: RichText(
              text: _LinkSpan(text, url, getLinkStyle(context)),
            ),
          ),
        ),
      ],
    );
  }
}

class _LinkSpan extends TextSpan {
  _LinkSpan(String text, String url, TextStyle? style)
    : super(
        text: text,
        style: style,
        mouseCursor: SystemMouseCursors.click,
        recognizer: TapGestureRecognizer()..onTap = () => launchUrl(Uri.parse(url)),
      );
}
