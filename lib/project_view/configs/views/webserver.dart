import "dart:convert";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../main_menu/settings/setting_heading.dart";
import "../../../project_configs_provider.dart";
import "../models/base.dart";
import "../models/webserver.dart";

class WebserverConfigView extends ConsumerStatefulWidget {
  const WebserverConfigView({super.key});

  @override
  ConsumerState<WebserverConfigView> createState() => _WebserverConfigViewState();
}

class _WebserverConfigViewState extends ConsumerState<WebserverConfigView> {
  ///reference to the actual mapConfig in the _projectProvider,
  ///so changing the model will properly apply
  late ConfigFile configFile;

  WebserverConfigModel get model => configFile.model as WebserverConfigModel;

  set model(WebserverConfigModel newModel) => configFile.model = newModel;

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
    configFile.changeValueInFile(
      WebserverConfigKeys.port,
      jsonEncode(model.port),
    );
  }

  @override
  Widget build(BuildContext context) {
    configFile = ref.watch(createTypedOpenConfigProvider<WebserverConfigModel>())!;

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
