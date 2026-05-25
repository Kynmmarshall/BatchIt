import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/core/app_routes.dart';
import 'package:batchit/providers/app_settings_provider.dart';
import 'package:batchit/services/settings_service.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:batchit/widgets/app_screen_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static final _settingsSvc = SettingsService();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<AppSettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: AppScreenContainer(
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.appPreferences,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SegmentedButton<String>(
                      segments: [
                        ButtonSegment<String>(value: 'en', label: Text(l10n.english)),
                        ButtonSegment<String>(value: 'fr', label: Text(l10n.french)),
                      ],
                      selected: {settings.locale.languageCode},
                      onSelectionChanged: (value) {
                        final lang = value.first;
                        context.read<AppSettingsProvider>().setLocale(Locale(lang));
                        _settingsSvc.updateSettings({'language': lang}).ignore();
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.switchTheme,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.system,
                          icon: Icon(Icons.brightness_auto_rounded),
                          label: Text('System'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          icon: Icon(Icons.light_mode_rounded),
                          label: Text('Light'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          icon: Icon(Icons.dark_mode_rounded),
                          label: Text('Dark'),
                        ),
                      ],
                      selected: {settings.themeMode},
                      onSelectionChanged: (value) {
                        final mode = value.first;
                        context.read<AppSettingsProvider>().setTheme(mode);
                        final modeStr = switch (mode) {
                          ThemeMode.dark => 'dark',
                          ThemeMode.light => 'light',
                          ThemeMode.system => 'system',
                        };
                        _settingsSvc.updateSettings({'theme': modeStr}).ignore();
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.accountPreferences,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.notifications_none_rounded),
                      title: Text(l10n.notificationsPreferences),
                      subtitle: Text(l10n.notificationsPreferences),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.notifications);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
