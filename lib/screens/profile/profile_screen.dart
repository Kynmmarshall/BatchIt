import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/providers/app_settings_provider.dart';
import 'package:batchit/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<AppSettingsProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              auth.user?.name ?? 'BatchIt User',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(auth.user?.email ?? 'user@batchit.app'),
            const SizedBox(height: 24),
            Text(l10n.changeLanguage, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: [
                ButtonSegment<String>(value: 'en', label: Text(l10n.english)),
                ButtonSegment<String>(value: 'fr', label: Text(l10n.french)),
              ],
              selected: {settings.locale.languageCode},
              onSelectionChanged: (value) {
                context.read<AppSettingsProvider>().setLocale(Locale(value.first));
              },
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: Text(l10n.switchTheme),
              value: settings.themeMode == ThemeMode.dark,
              onChanged: (_) {
                context.read<AppSettingsProvider>().toggleTheme();
              },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  context.read<AuthProvider>().logout();
                },
                child: Text(l10n.logout),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
