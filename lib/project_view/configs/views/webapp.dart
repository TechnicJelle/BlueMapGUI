import "dart:convert";

import "package:flutter/material.dart";

import "../../../main_menu/settings/setting_heading.dart";
import "../models/base.dart";
import "../models/webapp.dart";

class WebappConfigView extends StatefulWidget {
  final ConfigFile<WebappConfigModel> configFile;

  const WebappConfigView(this.configFile, {super.key});

  @override
  State<WebappConfigView> createState() => _WebappConfigViewState();
}

class _WebappConfigViewState extends State<WebappConfigView> {
  late WebappConfigModel config = widget.configFile.model;

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.only(bottom: 8);
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 12),
          child: Text(
            "Webapp Config",
            style: TextTheme.of(
              context,
            ).headlineMedium?.copyWith(color: TextTheme.of(context).titleSmall?.color),
          ),
        ),
        CheckboxListTile(
          title: SettingHeading(
            context,
            "Default to Flat View",
            padding: padding,
            const [
              SettingsBodyText(
                "Whether the webapp will default to flat-view instead of perspective-view.",
              ),
            ],
          ),
          value: config.defaultToFlatView,
          onChanged: (bool? value) {
            if (value == null) return;
            setState(() => config = config.copyWith(defaultToFlatView: value));

            widget.configFile.changeValueInFile(
              WebappConfigKeys.defaultToFlatView,
              jsonEncode(config.defaultToFlatView),
            );
          },
        ),
      ],
    );
  }
}
