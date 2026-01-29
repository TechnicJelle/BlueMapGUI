import "dart:convert";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../project_configs_provider.dart";
import "../models/base.dart";
import "../models/webapp.dart";
import "base.dart";

class WebappConfigView extends ConsumerStatefulWidget {
  const WebappConfigView({super.key});

  @override
  ConsumerState<WebappConfigView> createState() => _WebappConfigViewState();
}

class _WebappConfigViewState extends ConsumerState<WebappConfigView> {
  ///reference to the actual mapConfig in the _projectProvider,
  ///so changing the model will properly apply
  late ConfigFile configFile;

  WebappConfigModel get model => configFile.model as WebappConfigModel;

  set model(WebappConfigModel newModel) => configFile.model = newModel;

  @override
  Widget build(BuildContext context) {
    configFile = ref.watch(createTypedOpenConfigProvider<WebappConfigModel>())!;

    return ListView(
      children: [
        const ConfigTitle(title: "Webapp Config"),
        ToggleOption(
          title: "Default to Flat View",
          description:
              "Whether the webapp will default to flat-view instead of perspective-view.",
          value: model.defaultToFlatView,
          onChanged: (bool? value) {
            if (value == null) return;
            setState(() => model = model.copyWith(defaultToFlatView: value));

            configFile.changeValueInFile(
              WebappConfigKeys.defaultToFlatView,
              jsonEncode(model.defaultToFlatView),
            );
          },
        ),
      ],
    );
  }
}
