import "dart:math" as math;

import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_colorpicker/flutter_colorpicker.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../main_menu/settings/setting_heading.dart";
import "../../../utils.dart";
import "../config_gui.dart";
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
    return Center(
      child: config.modelOrProblem.match(
        (FileConfigFileLoadProblem e) {
          return const _OpenErrorDisplay(
            "Simple View currently not available for this config, due to errors.\n"
            "You can use Advanced Mode to fix them.",
          );
        },
        (T model) {
          return ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1500),
            child: switch (model) {
              CoreConfigModel() => const CoreConfigView(),
              StartupConfigModel() => const StartupConfigView(),
              WebappConfigModel() => const WebappConfigView(),
              WebserverConfigModel() => const WebserverConfigView(),
              MapConfigModel() => const MapConfigView(),
              _ => const _OpenErrorDisplay(
                "Simple View currently not available for this config.\n"
                "Please use Advanced Mode for this config.",
              ),
            },
          );
        },
      ),
    );
  }
}

class _OpenErrorDisplay extends ConsumerWidget {
  final String errorString;

  const _OpenErrorDisplay(this.errorString);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.red,
        ),
        child: Column(
          mainAxisSize: .min,
          children: [
            Text(errorString, textAlign: .center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.read(advancedModeProvider.notifier).set(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade100),
              child: const Text(
                "Switch to Advanced Mode",
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
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
          final String dialogTitle = "Pick your $purpose folder";
          String? picked;
          try {
            // First, we try with an initialDirectory:
            // - Linux will crash on this, if the path contains any special characters
            //   (I have submitted a PR to the file_picker library that will fix this: https://github.com/miguelpruivo/flutter_file_picker/pull/1963 )
            // - Windows will crash on this, if the directory does not exist
            picked = await FilePicker.platform.getDirectoryPath(
              dialogTitle: dialogTitle,
              initialDirectory: initialDirectory,
            );

            // Ignoring, because we want to catch all Errors and Exceptions, to give it a chance to try again.
            // If it still crashes after that, we let it go further up.
            // ignore: avoid_catches_without_on_clauses
          } catch (_) {
            // So if it crashed, we try again, but without an initialDirectory:
            picked = await FilePicker.platform.getDirectoryPath(
              dialogTitle: dialogTitle,
            );
          }
          if (picked == null) return;
          onPicked(picked);
        },
      ),
    );
  }
}

class ConfigOptionsList extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const ConfigOptionsList({required this.title, required this.children, super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          flexibleSpace: FlexibleSpaceBar(
            expandedTitleScale: 2,
            title: Text(
              title,
              style: TextTheme.of(context).headlineSmall?.copyWith(
                color: TextTheme.of(context).titleSmall?.color,
                fontWeight: .w500,
              ),
            ),
            // right: 200 is to ensure that the Advanced Mode switch does not overlap the title
            titlePadding: const EdgeInsets.only(left: 16, bottom: 12, right: 200),
          ),
          expandedHeight: 78,
          backgroundColor: Colors.transparent,
          pinned: true,
        ),
        SliverList.list(children: children),
      ],
    );
  }
}

class _Option extends StatefulWidget {
  static const EdgeInsets _settingHeadingPadding = .only(bottom: 8);

  final String title;
  final List<SettingsBodyBase> descriptionList;
  final Widget? subtitle;
  final Widget? button;
  final bool shouldPadBottom;

  const _Option({
    required this.title,
    required this.descriptionList,
    this.subtitle,
    this.button,
    this.shouldPadBottom = false,
  });

  @override
  State<_Option> createState() => _OptionState();
}

class _OptionState extends State<_Option> {
  Color? hoverColour;

  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    hoverColour ??= Theme.of(context).hoverColor;
    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: ListTile(
        title: SettingHeading(
          context,
          widget.title,
          padding: _Option._settingHeadingPadding,
          widget.descriptionList,
        ),
        subtitle: widget.shouldPadBottom
            ? Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: widget.subtitle,
              )
            : widget.subtitle,
        trailing: widget.button,
        tileColor: hovered ? hoverColour : null,
      ),
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
                style: pixelCode200,
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
  final double? value;
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
    final child = SliderTheme(
      data: const SliderThemeData(showValueIndicator: ShowValueIndicator.onDrag),
      child: _Option(
        title: title,
        descriptionList: descriptionList,
        subtitle: Column(
          children: [
            Row(
              children: [
                if (value != null)
                  Text(
                    value!.toStringAsFixed(2),
                    style: pixelCode200,
                  ),
                Expanded(
                  child: Slider(
                    value: value ?? max,
                    label: value?.toStringAsFixed(2) ?? "",
                    min: min,
                    max: math.max(value ?? max, max),
                    onChanged: value == null || value! > max ? null : onChanged,
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
    return value == null
        ? Tooltip(
            message: """
Config file does not contain this option! It is probably too old.
Button will be disabled until the config file contains the option.""",
            child: child,
          )
        : child;
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
  final FormFieldValidator<String>? warningValidator;

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
    this.warningValidator,
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
    this.warningValidator,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return _Option(
      title: title,
      descriptionList: descriptionList,
      subtitle: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: hintText,
          suffixIcon: button,
          errorStyle: const TextStyle(color: Colors.orange),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
        ),
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
        keyboardType: keyboardType,
        inputFormatters: inputFormatter != null ? [inputFormatter!] : null,
        validator: warningValidator,
        autovalidateMode: .onUserInteraction,
      ),
      shouldPadBottom: true,
    );
  }
}

class Vector2XZOption extends StatelessWidget {
  final String title;
  final List<SettingsBodyBase> descriptionList;
  final TextEditingController? controllerX;
  final TextEditingController? controllerZ;
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

    final child = _Option(
      title: title,
      descriptionList: descriptionList,
      subtitle: Row(
        children: [
          Flexible(
            child: TextField(
              enabled: controllerX != null,
              controller: controllerX,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "x",
                labelText: "x",
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
              enabled: controllerZ != null,
              controller: controllerZ,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "z",
                labelText: "z",
              ),
              onChanged: onChanged,
              onEditingComplete: onEditingComplete,
              keyboardType: keyboardType,
              inputFormatters: [inputFormatter],
            ),
          ),
        ],
      ),
      shouldPadBottom: true,
    );

    return controllerX != null && controllerZ != null
        ? child
        : Tooltip(
            message: """
Config file does not contain (some of) these options! It is probably too old.
Buttons will be disabled until the config file contains all the options.""",
            child: child,
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
    final child = CheckboxListTile(
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
      tristate: value == null,
      enabled: value != null,
      fillColor: value == null ? .all(Colors.grey) : null,
    );
    return value == null
        ? Tooltip(
            message: """
Config file does not contain this option! It is probably too old.
Button will be disabled until the config file contains the option.""",
            child: child,
          )
        : child;
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
          style: pixelCode400.copyWith(color: textColour),
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
  bool? enabled,
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
          tristate: option.enabled == null,
          fillColor: option.enabled == null ? .all(Colors.grey) : null,
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
        //To make up for the Checkbox's 8px of built-in padding:
        const SizedBox(width: 8),
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
          final bool enabled = !options.any((option) => option.enabled == null);
          final child = ToggleButtons(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            direction: constraints.maxWidth < breakpoint ? .vertical : .horizontal,
            onPressed: enabled
                ? (int index) {
                    final option = options[index];
                    option.onPressed(!option.enabled!);
                  }
                : null,
            isSelected: options
                .map((option) => option.enabled ?? false)
                .toList(growable: false),
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

          return enabled
              ? child
              : Tooltip(
                  message: """
Config file does not contain (some of) these options! It is probably too old.
Buttons will be disabled until the config file contains all the options.""",
                  child: child,
                );
        },
      ),
      shouldPadBottom: true,
    );
  }
}
