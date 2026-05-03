import 'package:batchit/core/app_routes.dart';
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/screens/orders/my_batches_screen.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:batchit/widgets/app_screen_container.dart';
import 'package:batchit/widgets/app_staggered_fade.dart';
import 'package:flutter/material.dart';

enum _NotificationType { batch, order, provider, reminder }
enum _NotificationAction { batchDetails, orders, settings, none }

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _batchAlerts = true;
  bool _orderAlerts = true;
  bool _providerAlerts = true;
  bool _showUnreadOnly = false;
  final Set<String> _readNotificationIds = {};

  static const List<_NotificationItem> _items = [
    _NotificationItem(
      id: 'batch-filled-1',
      group: _NotificationGroup.today,
      type: _NotificationType.batch,
      titleKey: 'batchFilledNotification',
      body: 'Your batch "Ain Sebaa Daily" has been filled. Join the batch to start shopping together.',
      timeLabel: 'Just now',
      action: _NotificationAction.batchDetails,
      actionArg: '1',
    ),
    _NotificationItem(
      id: 'order-ready-1',
      group: _NotificationGroup.today,
      type: _NotificationType.order,
      titleKey: 'orderReadyNotification',
      body: 'Your order from "Marjane Hypermarket" is ready for pickup at the collection point.',
      timeLabel: '2 hours ago',
      action: _NotificationAction.orders,
    ),
    _NotificationItem(
      id: 'provider-updated-1',
      group: _NotificationGroup.yesterday,
      type: _NotificationType.provider,
      titleKey: 'providerUpdatedNotification',
      body: 'Carrefour has updated their inventory. Check out new arrivals in Grocery.',
      timeLabel: 'Yesterday',
      action: _NotificationAction.none,
    ),
    _NotificationItem(
      id: 'batch-expired-1',
      group: _NotificationGroup.yesterday,
      type: _NotificationType.batch,
      titleKey: 'batchExpiredNotification',
      body: 'Your batch "Quick Groceries" has expired. Create a new batch to continue.',
      timeLabel: 'Yesterday',
      action: _NotificationAction.none,
    ),
    _NotificationItem(
      id: 'profile-reminder-1',
      group: _NotificationGroup.thisWeek,
      type: _NotificationType.reminder,
      titleKey: 'profileReminderNotification',
      body: 'Add your preferences so BatchIt can personalize your feed.',
      timeLabel: '5 days ago',
      action: _NotificationAction.settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    final visibleItems = _items.where((item) {
      if (_showUnreadOnly && _readNotificationIds.contains(item.id)) {
        return false;
      }
      switch (item.type) {
        case _NotificationType.batch:
          return _batchAlerts;
        case _NotificationType.order:
          return _orderAlerts;
        case _NotificationType.provider:
          return _providerAlerts;
        case _NotificationType.reminder:
          return true;
      }
    }).toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsScreenTitle),
        actions: [
          TextButton(
            onPressed: _readNotificationIds.length == _items.length
                ? null
                : () {
                    setState(() {
                      _readNotificationIds
                        ..clear()
                        ..addAll(_items.map((item) => item.id));
                    });
                  },
            child: Text(l10n.markAllRead),
          ),
        ],
      ),
      body: AppScreenContainer(
        child: ListView(
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
                        l10n.notificationsScreenSubtitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.notificationsScreenLead,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: [
                          FilterChip(
                            label: Text(l10n.notificationsScreenTitle),
                            selected: !_showUnreadOnly,
                            onSelected: (selected) {
                              setState(() => _showUnreadOnly = false);
                            },
                          ),
                          FilterChip(
                            label: Text(l10n.unreadOnly),
                            selected: _showUnreadOnly,
                            onSelected: (selected) {
                              setState(() => _showUnreadOnly = selected);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _PreferencesCard(
              batchAlerts: _batchAlerts,
              orderAlerts: _orderAlerts,
              providerAlerts: _providerAlerts,
              onBatchChanged: (value) => setState(() => _batchAlerts = value),
              onOrderChanged: (value) => setState(() => _orderAlerts = value),
              onProviderChanged: (value) => setState(() => _providerAlerts = value),
            ),
            const SizedBox(height: AppSpacing.md),
            if (visibleItems.isEmpty)
              _EmptyNotificationsState(l10n: l10n)
            else ...[
              _NotificationGroupSection(
                label: l10n.today,
                items: visibleItems.where((item) => item.group == _NotificationGroup.today).toList(growable: false),
                isRead: _readNotificationIds,
                onToggleRead: _toggleRead,
                l10n: l10n,
              ),
              const SizedBox(height: AppSpacing.md),
              _NotificationGroupSection(
                label: l10n.yesterday,
                items: visibleItems.where((item) => item.group == _NotificationGroup.yesterday).toList(growable: false),
                isRead: _readNotificationIds,
                onToggleRead: _toggleRead,
                l10n: l10n,
              ),
              const SizedBox(height: AppSpacing.md),
              _NotificationGroupSection(
                label: l10n.thisWeek,
                items: visibleItems.where((item) => item.group == _NotificationGroup.thisWeek).toList(growable: false),
                isRead: _readNotificationIds,
                onToggleRead: _toggleRead,
                l10n: l10n,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _toggleRead(String id) {
    setState(() {
      if (_readNotificationIds.contains(id)) {
        _readNotificationIds.remove(id);
      } else {
        _readNotificationIds.add(id);
      }
    });
  }
}

class _PreferencesCard extends StatelessWidget {
  const _PreferencesCard({
    required this.batchAlerts,
    required this.orderAlerts,
    required this.providerAlerts,
    required this.onBatchChanged,
    required this.onOrderChanged,
    required this.onProviderChanged,
  });

  final bool batchAlerts;
  final bool orderAlerts;
  final bool providerAlerts;
  final ValueChanged<bool> onBatchChanged;
  final ValueChanged<bool> onOrderChanged;
  final ValueChanged<bool> onProviderChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.notificationsPreferences,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.batchAlerts),
              subtitle: Text(l10n.batchAlertsSubtitle),
              value: batchAlerts,
              onChanged: onBatchChanged,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.orderAlerts),
              subtitle: Text(l10n.orderAlertsSubtitle),
              value: orderAlerts,
              onChanged: onOrderChanged,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.providerAlerts),
              subtitle: Text(l10n.providerAlertsSubtitle),
              value: providerAlerts,
              onChanged: onProviderChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationGroupSection extends StatelessWidget {
  const _NotificationGroupSection({
    required this.label,
    required this.items,
    required this.isRead,
    required this.onToggleRead,
    required this.l10n,
  });

  final String label;
  final List<_NotificationItem> items;
  final Set<String> isRead;
  final ValueChanged<String> onToggleRead;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.xs),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        ...items.map((item) {
          final unread = !isRead.contains(item.id);
          return AppStaggeredFade(
            index: items.indexOf(item) + 1,
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onToggleRead(item.id),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: unread
                                  ? Theme.of(context).colorScheme.primaryContainer
                                  : Theme.of(context).colorScheme.surfaceContainerHighest,
                              child: Icon(
                                item.icon,
                                color: unread
                                    ? Theme.of(context).colorScheme.onPrimaryContainer
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
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
                                          _titleForKey(l10n, item.titleKey),
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
                                            color: Theme.of(context).colorScheme.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.body,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Wrap(
                                    spacing: AppSpacing.sm,
                                    runSpacing: AppSpacing.xs,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      Text(
                                        item.timeLabel,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          onToggleRead(item.id);
                                          _performAction(context, item);
                                        },
                                        child: Text(l10n.viewDetails),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  String _titleForKey(AppLocalizations l10n, String key) {
    switch (key) {
      case 'batchFilledNotification':
        return l10n.batchFilledNotification;
      case 'orderReadyNotification':
        return l10n.orderReadyNotification;
      case 'providerUpdatedNotification':
        return l10n.providerUpdatedNotification;
      case 'batchExpiredNotification':
        return l10n.batchExpiredNotification;
      case 'profileReminderNotification':
        return l10n.profileReminderNotification;
      default:
        return key;
    }
  }

  void _performAction(BuildContext context, _NotificationItem item) {
    switch (item.action) {
      case _NotificationAction.batchDetails:
        Navigator.pushNamed(context, AppRoutes.batchDetails, arguments: item.actionArg);
        break;
      case _NotificationAction.orders:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MyBatchesScreen()),
        );
        break;
      case _NotificationAction.settings:
        Navigator.pushNamed(context, AppRoutes.settings);
        break;
      case _NotificationAction.none:
        break;
    }
  }
}

class _EmptyNotificationsState extends StatelessWidget {
  const _EmptyNotificationsState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.noNotificationsTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.noNotificationsSubtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

enum _NotificationGroup { today, yesterday, thisWeek }

class _NotificationItem {
  const _NotificationItem({
    required this.id,
    required this.group,
    required this.type,
    required this.titleKey,
    required this.body,
    required this.timeLabel,
    required this.action,
    this.actionArg,
  });

  final String id;
  final _NotificationGroup group;
  final _NotificationType type;
  final String titleKey;
  final String body;
  final String timeLabel;
  final _NotificationAction action;
  final String? actionArg;

  IconData get icon {
    switch (type) {
      case _NotificationType.batch:
        return Icons.inventory_2_outlined;
      case _NotificationType.order:
        return Icons.receipt_long_outlined;
      case _NotificationType.provider:
        return Icons.storefront_outlined;
      case _NotificationType.reminder:
        return Icons.person_outline_rounded;
    }
  }
}
