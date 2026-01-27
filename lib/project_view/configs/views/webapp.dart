import "dart:convert";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../main_menu/settings/setting_heading.dart";
import "../../../project_configs_provider.dart";
import "../models/base.dart";
import "../models/webapp.dart";

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

    const padding = EdgeInsets.only(bottom: 8);
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 12),
          child: Text(
            "Webapp Config",
            style: TextTheme.of(context).headlineMedium?.copyWith(
              color: TextTheme.of(context).titleSmall?.color,
            ),
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
