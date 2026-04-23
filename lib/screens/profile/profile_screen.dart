import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/providers/app_settings_provider.dart';
import 'package:batchit/providers/auth_provider.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:batchit/widgets/app_screen_container.dart';
import 'package:batchit/widgets/app_staggered_fade.dart';
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
      body: AppScreenContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppStaggeredFade(
              index: 0,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.user?.name ?? 'BatchIt User',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(auth.user?.email ?? 'user@batchit.app'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppStaggeredFade(
              index: 1,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.changeLanguage, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.xs),
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
            ),
            const Spacer(),
            AppStaggeredFade(
              index: 2,
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.read<AuthProvider>().logout();
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(l10n.logout),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
