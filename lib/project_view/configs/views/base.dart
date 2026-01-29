import "dart:io";
import "dart:math" as math;

import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "../../../main_menu/settings/setting_heading.dart";
import "../../../utils.dart";
import "../models/base.dart";
import "../models/core.dart";
import "../models/map.dart";
import "../models/startup.dart";
import "../models/webapp.dart";
import "../models/webserver.dart";
import "core.dart";
import "map.dart";
import "startup.dart";
import "webapp.dart";
import "webserver.dart";

class BaseConfigView<T extends BaseConfigModel> extends StatelessWidget {
  final ConfigFile<T> config;

  const BaseConfigView(this.config, {super.key});

  @override
  Widget build(BuildContext context) {
    final T model = config.model;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1500),
        child: switch (model) {
          CoreConfigModel() => const CoreConfigView(),
          StartupConfigModel() => const StartupConfigView(),
          WebappConfigModel() => const WebappConfigView(),
          WebserverConfigModel() => const WebserverConfigView(),
          MapConfigModel() => const MapConfigView(),
          _ => const Center(
            child: Text(
              "Simple view currently not available for this config.\n"
              "Please use the Advanced Mode for this config.",
              textAlign: .center,
            ),
          ),
        },
      ),
    );
  }
}

class PathPickerButton extends StatelessWidget {
  final String purpose;
  final void Function(String path) onPicked;
  final String initialDirectory;

  const PathPickerButton({
    required this.purpose,
    required this.onPicked,
    required this.initialDirectory,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .symmetric(horizontal: 6),
      child: TextButton.icon(
        icon: const Icon(Icons.drive_folder_upload_rounded),
        label: Text("Pick $purpose folder"),
        onPressed: () async {
          final initialDir = Directory(initialDirectory);
          final String? picked = await FilePicker.platform.getDirectoryPath(
            dialogTitle: "Pick your $purpose folder",
            initialDirectory: initialDir.existsSync() ? initialDirectory : null,
          );
          if (picked == null) return;
          onPicked(picked);
        },
      ),
    );
  }
}

class ConfigTitle extends StatelessWidget {
  final String title;

  const ConfigTitle({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .only(left: 16, top: 16, bottom: 12),
      child: Text(
        title,
        style: TextTheme.of(context).headlineMedium?.copyWith(
          color: TextTheme.of(context).titleSmall?.color,
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  static const EdgeInsets _settingHeadingPadding = .only(bottom: 8);

  final String title;
  final List<SettingsBodyBase> descriptionList;
  final Widget? subtitle;

  const _Option({
    required this.title,
    required this.descriptionList,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: SettingHeading(
        context,
        title,
        padding: _settingHeadingPadding,
        descriptionList,
      ),
      subtitle: subtitle,
    );
  }
}

class IntSliderOption extends StatelessWidget {
  final String title;
  final List<SettingsBodyBase> descriptionList;
  final int value;
  final int min;
  final int max;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;
  final Color? sliderColor;
  final Text? warning;

  IntSliderOption({
    required this.title,
    required String description,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.onChangeEnd,
    this.sliderColor,
    this.warning,
    super.key,
  }) : descriptionList = [SettingsBodyText(description)];

  const IntSliderOption.customDescription({
    required this.title,
    required this.descriptionList,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.onChangeEnd,
    this.sliderColor,
    this.warning,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return _Option(
      title: title,
      descriptionList: descriptionList,
      subtitle: Column(
        children: [
          Row(
            children: [
              Text(
                value.toString().padLeft(max.toString().length),
                style: pixelCode,
              ),
              Expanded(
                child: max > 1
                    ? Slider(
                        value: value.toDouble(),
                        label: value.toString(),
                        min: min.toDouble(),
                        max: math.max(value, max).toDouble(),
                        divisions: max - 1,
                        onChanged: value > max ? null : onChanged,
                        onChangeEnd: onChangeEnd,
                        activeColor: sliderColor,
                      )
                    : const Slider(value: 1, onChanged: null),
              ),
            ],
          ),
          ?warning,
        ],
      ),
    );
  }
}

class TextFieldOption extends StatelessWidget {
  final String title;
  final List<SettingsBodyBase> descriptionList;
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback onEditingComplete;
  final Widget? button;
  final TextInputType? keyboardType;
  final TextInputFormatter? inputFormatter;

  TextFieldOption({
    required this.title,
    required String description,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    required this.onEditingComplete,
    this.button,
    this.keyboardType,
    this.inputFormatter,
    super.key,
  }) : descriptionList = [SettingsBodyText(description)];

  const TextFieldOption.customDescription({
    required this.title,
    required this.descriptionList,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    required this.onEditingComplete,
    this.button,
    this.keyboardType,
    this.inputFormatter,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return _Option(
      title: title,
      descriptionList: descriptionList,
      subtitle: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: hintText,
          suffixIcon: button,
        ),
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
        keyboardType: keyboardType,
        inputFormatters: inputFormatter != null ? [inputFormatter!] : null,
      ),
    );
  }
}

class ToggleOption extends StatelessWidget {
  final String title;
  final List<SettingsBodyBase> descriptionList;
  final bool? value;
  final ValueChanged<bool> onChanged;

  ToggleOption({
    required this.title,
    required String description,
    required this.value,
    required this.onChanged,
    super.key,
  }) : descriptionList = [SettingsBodyText(description)];

  const ToggleOption.customDescription({
    required this.title,
    required this.descriptionList,
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: SettingHeading(
        context,
        title,
        padding: _Option._settingHeadingPadding,
        descriptionList,
      ),
      value: value,
      onChanged: (bool? value) {
        if (value == null) return;
        onChanged(value);
      },
    );
  }
}
