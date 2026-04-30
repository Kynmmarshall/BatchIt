import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/providers/app_settings_provider.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:batchit/widgets/app_screen_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
                        ButtonSegment<String>(
                          value: 'en',
                          label: Text(l10n.english),
                        ),
                        ButtonSegment<String>(
                          value: 'fr',
                          label: Text(l10n.french),
                        ),
                      ],
                      selected: {settings.locale.languageCode},
                      onSelectionChanged: (value) {
                        context
                            .read<AppSettingsProvider>()
                            .setLocale(Locale(value.first));
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.switchTheme),
                      value: settings.themeMode == ThemeMode.dark,
                      onChanged: (_) {
                        context.read<AppSettingsProvider>().toggleTheme();
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
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.language_rounded),
                      title: Text(l10n.language),
                      subtitle: Text(l10n.changeLanguage),
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
