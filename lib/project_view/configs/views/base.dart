import "dart:io";
import "dart:math" as math;

import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_colorpicker/flutter_colorpicker.dart";

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
  final Widget? button;

  const _Option({
    required this.title,
    required this.descriptionList,
    this.subtitle,
    this.button,
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
      trailing: button,
    );
  }
}

class IntSliderOption extends StatelessWidget {
  final String title;
  final List<SettingsBodyBase> descriptionList;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final ValueChanged<int> onChangeEnd;
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
                        onChanged: value > max ? null : (d) => onChanged(d.toInt()),
                        onChangeEnd: (d) => onChangeEnd(d.toInt()),
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

class DoubleSliderOption extends StatelessWidget {
  final String title;
  final List<SettingsBodyBase> descriptionList;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;
  final Color? sliderColor;
  final Text? warning;

  DoubleSliderOption({
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

  const DoubleSliderOption.customDescription({
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
    return SliderTheme(
      data: const SliderThemeData(showValueIndicator: ShowValueIndicator.onDrag),
      child: _Option(
        title: title,
        descriptionList: descriptionList,
        subtitle: Column(
          children: [
            Row(
              children: [
                Text(
                  value.toStringAsFixed(2),
                  style: pixelCode,
                ),
                Expanded(
                  child: Slider(
                    value: value,
                    label: value.toStringAsFixed(2),
                    min: min,
                    max: math.max(value, max),
                    onChanged: value > max ? null : onChanged,
                    onChangeEnd: onChangeEnd,
                    activeColor: sliderColor,
                  ),
                ),
              ],
            ),
            ?warning,
          ],
        ),
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

class Vector2XZOption extends StatelessWidget {
  final String title;
  final List<SettingsBodyBase> descriptionList;
  final TextEditingController controllerX;
  final TextEditingController controllerZ;
  final ValueChanged<String>? onChanged;
  final VoidCallback onEditingComplete;

  Vector2XZOption({
    required this.title,
    required String description,
    required this.controllerX,
    required this.controllerZ,
    required this.onChanged,
    required this.onEditingComplete,
    super.key,
  }) : descriptionList = [SettingsBodyText(description)];

  const Vector2XZOption.customDescription({
    required this.title,
    required this.descriptionList,
    required this.controllerX,
    required this.controllerZ,
    required this.onChanged,
    required this.onEditingComplete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const TextInputType keyboardType = .numberWithOptions(
      decimal: false,
      signed: true,
    );
    final TextInputFormatter inputFormatter = .withFunction((
      TextEditingValue oldValue,
      TextEditingValue newValue,
    ) {
      if (newValue.text.isEmpty) return newValue;
      if (newValue.text == "-") return newValue;
      final int? intValue = int.tryParse(newValue.text);
      if (intValue != null) {
        return newValue;
      }
      return oldValue;
    });

    return _Option(
      title: title,
      descriptionList: descriptionList,
      subtitle: Row(
        children: [
          Flexible(
            child: TextField(
              controller: controllerX,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "x",
              ),
              onChanged: onChanged,
              onEditingComplete: onEditingComplete,
              keyboardType: keyboardType,
              inputFormatters: [inputFormatter],
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: TextField(
              controller: controllerZ,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "z",
              ),
              onChanged: onChanged,
              onEditingComplete: onEditingComplete,
              keyboardType: keyboardType,
              inputFormatters: [inputFormatter],
            ),
          ),
        ],
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

class ColourOption extends StatelessWidget {
  final String title;
  final List<SettingsBodyBase> descriptionList;
  final Color colour;
  final String label;
  final void Function(Color colour, String hex) onPicked;

  ColourOption({
    required this.title,
    required String description,
    required this.colour,
    required this.label,
    required this.onPicked,
    super.key,
  }) : descriptionList = [SettingsBodyText(description)];

  const ColourOption.customDescription({
    required this.title,
    required this.descriptionList,
    required this.colour,
    required this.label,
    required this.onPicked,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textColour = getTextColourForBackground(colour);
    return _Option(
      title: title,
      descriptionList: descriptionList,
      button: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: colour),
        icon: Icon(Icons.color_lens, color: textColour),
        label: Text(
          label,
          style: pixelCode.copyWith(color: textColour, fontWeight: .w400),
        ),
        onPressed: () async {
          final pickedColour = await showDialog<Color>(
            context: context,
            builder: (BuildContext context) {
              Color pickingColour = colour;
              final controller = TextEditingController(
                text: label.replaceFirst("#", ""),
              );
              return AlertDialog(
                title: const Text("Pick a colour"),
                scrollable: true,
                content: Column(
                  children: [
                    ColorPicker(
                      pickerColor: colour,
                      onColorChanged: (Color value) => pickingColour = value,
                      displayThumbColor: true,
                      paletteType: PaletteType.hsv,
                      labelTypes: const [],
                      hexInputController: controller,
                      enableAlpha: false,
                      portraitOnly: true,
                    ),
                    TextFormField(
                      controller: controller,
                      decoration: const InputDecoration(
                        labelText: "Colour (in hex)",
                        prefixText: "#",
                      ),
                      autofocus: true,
                      maxLength: 6,
                      inputFormatters: [
                        UpperCaseTextFormatter(),
                        FilteringTextInputFormatter.allow(RegExp(kValidHexPattern)),
                      ],
                      onEditingComplete: () => Navigator.of(context).pop(pickingColour),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    child: const Text("Cancel"),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  TextButton(
                    child: const Text("Confirm"),
                    onPressed: () => Navigator.of(context).pop(pickingColour),
                  ),
                ],
              );
            },
          );
          if (pickedColour == null) return; //Dialog was dismissed
          final String hex = colorToHex(
            pickedColour,
            includeHashSign: true,
            enableAlpha: false,
          );
          onPicked(pickedColour, hex);
        },
      ),
    );
  }
}

typedef BoolListOptionType = ({
  IconData icon,
  String label,
  String description,
  bool enabled,
  ValueChanged<bool> onPressed,
});

class BoolListOption extends StatelessWidget {
  final String title;
  final List<SettingsBodyBase> descriptionList;
  final List<BoolListOptionType> options;
  final double breakpoint;
  final BoxConstraints? buttonSize;
  final double? horizontalPadding;

  BoolListOption({
    required this.title,
    required String description,
    required this.breakpoint,
    required this.options,
    this.buttonSize,
    this.horizontalPadding,
    super.key,
  }) : descriptionList = [SettingsBodyText(description)];

  const BoolListOption.customDescription({
    required this.title,
    required this.descriptionList,
    required this.breakpoint,
    required this.options,
    this.buttonSize,
    this.horizontalPadding,
    super.key,
  });

  Widget _generateButton(BoolListOptionType option) {
    return Row(
      children: [
        SizedBox(width: horizontalPadding),
        Checkbox(
          value: option.enabled,
          mouseCursor: .defer,
          onChanged: null,
        ),
        const SizedBox(width: 8),
        Column(
          mainAxisSize: .min,
          crossAxisAlignment: .start,
          children: [
            Row(
              children: [
                Text(
                  option.label,
                  style: const TextStyle(fontSize: 16, fontWeight: .w500),
                ),
                const SizedBox(width: 10),
                Icon(option.icon),
              ],
            ),
            const SizedBox(height: 6),
            Text(option.description),
          ],
        ),
        const SizedBox(width: 8), //To make up for the Checkbox's 8px of built-in padding
        SizedBox(width: horizontalPadding),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _Option(
      title: title,
      descriptionList: descriptionList,
      subtitle: LayoutBuilder(
        builder: (context, constraints) {
          return ToggleButtons(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            direction: constraints.maxWidth < breakpoint ? .vertical : .horizontal,
            onPressed: (index) {
              final option = options[index];
              option.onPressed(!option.enabled);
            },
            isSelected: options.map((option) => option.enabled).toList(growable: false),
            children: options
                .map((option) {
                  final button = _generateButton(option);
                  final thisButtonSize = buttonSize;
                  if (thisButtonSize == null) return button;
                  return ConstrainedBox(
                    constraints: thisButtonSize,
                    child: button,
                  );
                })
                .toList(growable: false),
          );
        },
      ),
    );
  }
}
