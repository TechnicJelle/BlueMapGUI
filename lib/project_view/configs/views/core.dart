import "dart:convert";
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../main_menu/settings/setting_heading.dart";
import "../../../project_configs_provider.dart";
import "../models/base.dart";
import "../models/core.dart";
import "base.dart";

class CoreConfigView extends ConsumerStatefulWidget {
  const CoreConfigView({super.key});

  @override
  ConsumerState<CoreConfigView> createState() => _CoreConfigViewState();
}

class _CoreConfigViewState extends ConsumerState<CoreConfigView> {
  ///reference to the actual mapConfig in the _projectProvider,
  ///so changing the model will properly apply
  late ConfigFile configFile;

  CoreConfigModel get model => configFile.model as CoreConfigModel;

  set model(CoreConfigModel newModel) => configFile.model = newModel;

  @override
  Widget build(BuildContext context) {
    configFile = ref.watch(createTypedOpenConfigProvider<CoreConfigModel>())!;

    final int cpus = Platform.numberOfProcessors;

    final Color? sliderColor;
    if (model.renderThreadCount >= cpus - 1 && model.renderThreadCount != 1) {
      sliderColor = Colors.red;
    } else if (model.renderThreadCount > cpus * 0.75 && cpus > 2) {
      sliderColor = Colors.orange;
    } else if (model.renderThreadCount > cpus * 0.5 && cpus > 2) {
      sliderColor = Colors.yellow;
    } else {
      sliderColor = null;
    }

    return ListView(
      children: [
        const ConfigTitle(title: "Core Config"),
        ToggleOption.customDescription(
          title: "Accept Download",
          descriptionList: const [
            SettingsBodyText(
              "By enabling this setting you are indicating that you have accepted ",
            ),
            SettingsBodyLink(
              "Mojang's EULA",
              "https://account.mojang.com/documents/minecraft_eula",
            ),
            SettingsBodyText(
              ", you confirm that you own a license to Minecraft (Java Edition) and you accept that BlueMap will download and use a Minecraft client file (depending on the Minecraft version) from ",
            ),
            SettingsBodyLink("Mojang's servers", "https://piston-meta.mojang.com/"),
            SettingsBodyText(" for you.\n"),
            SettingsBodyText(
              "This file contains resources that belong to Mojang and you must not redistribute it or do anything else that is not compliant with Mojang's EULA.",
            ),
            SettingsBodyText(
              "BlueMap uses resources in this file to generate the 3D models used for the map and texture them. Without these, BlueMap will not work.",
            ),
          ],
          value: model.acceptDownload,
          onChanged: (bool value) {
            setState(() => model = model.copyWith(acceptDownload: value));

            configFile.changeValueInFile(
              CoreConfigKeys.acceptDownload,
              jsonEncode(model.acceptDownload),
            );
          },
        ),
        IntSliderOption(
          title: "Render Thread Count",
          description: """
This changes the amount of threads that BlueMap will use to render the maps.
A higher value can improve the render speed, but could impact performance on the host machine.
Be careful with setting this too high, as your whole computer may start to lag!""",
          value: model.renderThreadCount,
          min: 1,
          max: cpus,
          onChanged: (int value) => setState(() {
            model = model.copyWith(renderThreadCount: value);
          }),
          onChangeEnd: (_) => configFile.changeValueInFile(
            CoreConfigKeys.renderThreadCount,
            jsonEncode(model.renderThreadCount),
          ),
          sliderColor: sliderColor,
          warning: sliderColor != null
              ? Text(
                  "Warning! Setting the Render Threads this high may cause your entire computer to start lagging and freezing!",
                  style: TextStyle(color: sliderColor, fontWeight: .bold, fontSize: 15),
                )
              : null,
        ),
      ],
    );
  }
}
