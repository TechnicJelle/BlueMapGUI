import "dart:convert";
import "dart:io";
import "dart:math";

import "package:flutter/material.dart";

import "../../../main_menu/settings/setting_heading.dart";
import "../../../utils.dart";
import "../models/base.dart";
import "../models/core.dart";

class CoreConfigView extends StatefulWidget {
  final ConfigFile<CoreConfigModel> configFile;

  const CoreConfigView(this.configFile, {super.key});

  @override
  State<CoreConfigView> createState() => _CoreConfigViewState();
}

class _CoreConfigViewState extends State<CoreConfigView> {
  late CoreConfigModel config = widget.configFile.model;

  @override
  Widget build(BuildContext context) {
    final int cpus = Platform.numberOfProcessors;

    final Color? sliderColor;
    if (config.renderThreadCount >= cpus - 1 && config.renderThreadCount != 1) {
      sliderColor = Colors.red;
    } else if (config.renderThreadCount > cpus * 0.75 && cpus > 2) {
      sliderColor = Colors.orange;
    } else if (config.renderThreadCount > cpus * 0.5 && cpus > 2) {
      sliderColor = Colors.yellow;
    } else {
      sliderColor = null;
    }

    const padding = EdgeInsets.only(bottom: 8);
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 12),
          child: Text(
            "Core Config",
            style: TextTheme.of(context).headlineMedium?.copyWith(
              color: TextTheme.of(context).titleSmall?.color,
            ),
          ),
        ),
        CheckboxListTile(
          title: SettingHeading(
            context,
            "Accept Download",
            padding: padding,
            const [
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
          ),
          value: config.acceptDownload,
          onChanged: (bool? value) {
            if (value == null) return;
            setState(() => config = config.copyWith(acceptDownload: value));

            widget.configFile.changeValueInFile(
              CoreConfigKeys.acceptDownload,
              jsonEncode(config.acceptDownload),
            );
          },
        ),
        ListTile(
          title: SettingHeading(
            context,
            "Render Thread Count",
            padding: padding,
            const [
              SettingsBodyText(
                """
This changes the amount of threads that BlueMap will use to render the maps.
A higher value can improve the render speed, but could impact performance on the host machine.
Be careful with setting this too high, as your whole computer may start to lag!""",
              ),
            ],
          ),
          subtitle: Column(
            children: [
              Row(
                children: [
                  Text(
                    config.renderThreadCount.toString().padLeft(cpus.toString().length),
                    style: pixelCode,
                  ),
                  Expanded(
                    child: cpus > 1
                        ? Slider(
                            value: config.renderThreadCount.toDouble(),
                            label: config.renderThreadCount.toString(),
                            min: 1,
                            max: max(config.renderThreadCount, cpus).toDouble(),
                            divisions: cpus - 1,
                            onChanged: config.renderThreadCount > cpus
                                ? null
                                : (double value) => setState(() {
                                    config = config.copyWith(
                                      renderThreadCount: value.toInt(),
                                    );
                                  }),
                            activeColor: sliderColor,
                            onChangeEnd: (_) => widget.configFile.changeValueInFile(
                              CoreConfigKeys.renderThreadCount,
                              jsonEncode(config.renderThreadCount),
                            ),
                          )
                        : const Slider(value: 1, onChanged: null),
                  ),
                ],
              ),
              if (sliderColor != null)
                Text(
                  "Warning! Setting the Render Threads this high may cause your entire computer to start lagging and freezing!",
                  style: TextStyle(color: sliderColor, fontWeight: .bold, fontSize: 15),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
