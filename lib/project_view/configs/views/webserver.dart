import "dart:convert";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../project_configs_provider.dart";
import "../models/base.dart";
import "../models/webserver.dart";
import "base.dart";

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

    return ListView(
      children: [
        const ConfigTitle(title: "Webserver Config"),
        TextFieldOption(
          title: "Port",
          description: "The port that the webserver listens on.",
          controller: portController,
          hintText: "Must not be empty!",
          keyboardType: const .numberWithOptions(decimal: false, signed: false),
          inputFormatter: TextInputFormatter.withFunction((
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
          onChanged: null,
          onEditingComplete: () => setState(validateAndSavePort),
        ),
      ],
    );
  }
}
