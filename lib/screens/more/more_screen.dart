import 'package:batchit/core/app_routes.dart';
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/providers/auth_provider.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:batchit/widgets/app_screen_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = context.watch<AuthProvider>().user;
    final isStaff = user?.isStaff ?? false;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.more)),
      body: AppScreenContainer(
        child: ListView(
          children: [
            _MoreOptionTile(
              icon: Icons.map_outlined,
              title: l10n.mapViewTitle,
              subtitle: l10n.mapViewLead,
              onTap: () => Navigator.pushNamed(context, AppRoutes.mapView),
            ),
            _MoreOptionTile(
              icon: Icons.chat_bubble_outline_rounded,
              title: l10n.chatTitle,
              subtitle: l10n.chatLead,
              onTap: () => Navigator.pushNamed(context, AppRoutes.chat),
            ),
            _MoreOptionTile(
              icon: Icons.storefront_outlined,
              title: l10n.providerDiscovery,
              subtitle: l10n.providerDiscoverySubtitle,
              onTap: () => Navigator.pushNamed(context, AppRoutes.providerDiscovery),
            ),
            _MoreOptionTile(
              icon: Icons.notifications_none_rounded,
              title: l10n.notificationsScreenTitle,
              subtitle: l10n.moreNotificationsSubtitle,
              onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
            ),
            _MoreOptionTile(
              icon: Icons.settings_outlined,
              title: l10n.settings,
              subtitle: l10n.moreSettingsSubtitle,
              onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
            ),
            if (isStaff) ...[
              const Divider(height: AppSpacing.lg),
              _MoreOptionTile(
                icon: Icons.admin_panel_settings_outlined,
                title: 'Admin — Provider Verification',
                subtitle: 'Review and approve or reject pending provider profiles',
                onTap: () => Navigator.pushNamed(context, AppRoutes.adminProviders),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MoreOptionTile extends StatelessWidget {
  const _MoreOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
