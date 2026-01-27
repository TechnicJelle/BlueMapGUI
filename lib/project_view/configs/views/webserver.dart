import "dart:convert";

import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "../../../main_menu/settings/setting_heading.dart";
import "../models/base.dart";
import "../models/webserver.dart";

class WebserverConfigView extends StatefulWidget {
  final ConfigFile<WebserverConfigModel> configFile;

  const WebserverConfigView(this.configFile, {super.key});

  @override
  State<WebserverConfigView> createState() => _WebserverConfigViewState();
}

class _WebserverConfigViewState extends State<WebserverConfigView> {
  late WebserverConfigModel model = widget.configFile.model;

  late final TextEditingController portController = TextEditingController(
    text: model.port.toString(),
  );

  @override
  void dispose() {
    validateAndSavePort();
    portController.dispose();
    super.dispose();
  }

  void validateAndSavePort() {
    final int? intValue = int.tryParse(portController.text);
    if (intValue == null) return;
    model = model.copyWith(port: intValue);
    widget.configFile.changeValueInFile(
      WebserverConfigKeys.port,
      jsonEncode(model.port),
    );
  }

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.only(bottom: 8);
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 12),
          child: Text(
            "Webserver Config",
            style: TextTheme.of(context).headlineMedium?.copyWith(
              color: TextTheme.of(context).titleSmall?.color,
            ),
          ),
        ),
        ListTile(
          title: SettingHeading(
            context,
            "Port",
            padding: padding,
            const [
              SettingsBodyText("The port that the webserver listens on."),
            ],
          ),
          subtitle: TextField(
            controller: portController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Must not be empty!",
            ),
            keyboardType: const .numberWithOptions(decimal: false, signed: false),
            inputFormatters: [
              TextInputFormatter.withFunction((
                TextEditingValue oldValue,
                TextEditingValue newValue,
              ) {
                if (newValue.text.isEmpty) return newValue;
                final int? intValue = int.tryParse(newValue.text);
                if (intValue != null && intValue > 0 && intValue <= 65535) {
                  return newValue;
                }
                return oldValue;
              }),
            ],
            onEditingComplete: () => setState(validateAndSavePort),
          ),
        ),
      ],
    );
  }
}
