import 'package:batchit/core/app_routes.dart';
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/models/notification_item.dart';
import 'package:batchit/providers/notification_provider.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:batchit/widgets/app_screen_container.dart';
import 'package:batchit/widgets/app_staggered_fade.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _showUnreadOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<NotificationProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<NotificationProvider>();
    final scheme = Theme.of(context).colorScheme;

    final visible = _showUnreadOnly
        ? provider.notifications.where((n) => !n.isRead).toList()
        : provider.notifications;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsScreenTitle),
        actions: [
          TextButton(
            onPressed: provider.unreadCount == 0
                ? null
                : () => provider.markAllRead(),
            child: Text(l10n.markAllRead),
          ),
        ],
      ),
      body: AppScreenContainer(
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  AppStaggeredFade(
                    index: 0,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Wrap(
                          spacing: AppSpacing.xs,
                          children: [
                            FilterChip(
                              label: Text(l10n.notificationsScreenTitle),
                              selected: !_showUnreadOnly,
                              onSelected: (_) => setState(() => _showUnreadOnly = false),
                            ),
                            FilterChip(
                              label: Text(l10n.unreadOnly),
                              selected: _showUnreadOnly,
                              onSelected: (v) => setState(() => _showUnreadOnly = v),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (visible.isEmpty)
                    _EmptyState(l10n: l10n)
                  else
                    ...visible.asMap().entries.map((e) => AppStaggeredFade(
                          index: e.key + 1,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: _NotificationCard(
                              notif: e.value,
                              scheme: scheme,
                              onTap: () => _handleTap(e.value, provider),
                            ),
                          ),
                        )),
                ],
              ),
      ),
    );
  }

  void _handleTap(AppNotification notif, NotificationProvider provider) {
    if (!notif.isRead) provider.markRead(notif.id);
    if (notif.relatedBatchId != null) {
      if (notif.type == 'batch_full' || notif.type == 'provider_message') {
        Navigator.pushNamed(context, AppRoutes.batchDetails,
            arguments: notif.relatedBatchId);
      }
    }
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notif,
    required this.scheme,
    required this.onTap,
  });

  final AppNotification notif;
  final ColorScheme scheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unread = !notif.isRead;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: unread
                    ? scheme.primaryContainer
                    : scheme.surfaceContainerHighest,
                child: Icon(
                  _iconForType(notif.type),
                  color: unread ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        if (unread)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(notif.body,
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _formatTime(notif.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'batch_full':
        return Icons.inventory_2_outlined;
      case 'provider_approved':
        return Icons.verified_outlined;
      case 'provider_rejected':
        return Icons.cancel_outlined;
      case 'provider_message':
        return Icons.storefront_outlined;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: AppSpacing.sm),
            Text(l10n.noNotificationsTitle,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(l10n.noNotificationsSubtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
