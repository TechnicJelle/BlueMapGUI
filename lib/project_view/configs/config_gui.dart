import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:freezed_annotation/freezed_annotation.dart";

import "../../project_configs_provider.dart";
import "advanced_editor.dart";
import "models/base.dart";
import "views/base.dart";

part "config_gui.freezed.dart";

@freezed
sealed class AdvancedMode with _$AdvancedMode {
  // The function name and lack of other parameters makes it clear enough
  // ignore: avoid_positional_boolean_parameters
  const factory AdvancedMode.data(bool value) = AdvancedModeData;

  const factory AdvancedMode.loading() = AdvancedModeLoading;
}

class AdvancedModeNotifier extends Notifier<AdvancedMode> {
  @override
  AdvancedMode build() {
    return const .data(false);
  }

  // The function name and lack of other parameters makes it clear enough
  // ignore: avoid_positional_boolean_parameters
  void set(bool newState) {
    if (newState) {
      // advanced mode was just enabled; that goes instantly
      state = .data(newState);
    } else {
      // advanced mode was just disabled, so we need to re-read the file into the models again
      state = const .loading();
      // wait a frame for the file to be properly saved on dispose of the advanced editor
      // this cannot be called there, because it's not allowed to red.read in a dispose()
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final ConfigFile openConfig = ref.read(openConfigProvider)!;
        await ref.read(projectProviderNotifier).refreshConfigFile(openConfig.file);
        state = .data(newState);
      });
    }
  }
}

class ConfigGUI extends ConsumerWidget {
  const ConfigGUI({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ConfigFile openConfig = ref.watch(openConfigProvider)!;
    final AdvancedMode advancedMode = ref.watch(advancedModeProvider);

    return Stack(
      children: [
        advancedMode.when(
          data: (val) => val ? AdvancedEditor(openConfig) : BaseConfigView(openConfig),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
        const AdvancedModeToggle(),
      ],
    );
  }
}

// I don't want these for providers; too long
// ignore: specify_nonobvious_property_types
final advancedModeProvider = NotifierProvider(AdvancedModeNotifier.new);

class AdvancedModeToggle extends ConsumerWidget {
  const AdvancedModeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AdvancedMode advancedMode = ref.watch(advancedModeProvider);
    final bool enabled = advancedMode.when(data: (value) => value, loading: () => true);
    final bool loading = advancedMode is AdvancedModeLoading;

    return Align(
      alignment: .topRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 12, top: 8),
        child: Row(
          mainAxisSize: .min,
          children: [
            Text(
              "Advanced Mode",
              style: TextStyle(
                color: enabled ? Colors.white : TextTheme.of(context).bodyLarge?.color,
              ),
            ),
            Switch(
              value: enabled,
              onChanged: loading
                  ? null
                  : (bool justSwitchedToAdvancedMode) => ref
                        .read(advancedModeProvider.notifier)
                        .set(justSwitchedToAdvancedMode),
            ),
          ],
        ),
      ),
    );
  }
}
