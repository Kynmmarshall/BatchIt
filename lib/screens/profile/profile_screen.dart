import 'package:batchit/core/app_routes.dart';
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/models/order.dart';
import 'package:batchit/providers/app_settings_provider.dart';
import 'package:batchit/providers/auth_provider.dart';
import 'package:batchit/providers/order_provider.dart';
import 'package:batchit/screens/orders/my_orders_screen.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:batchit/widgets/app_screen_container.dart';
import 'package:batchit/widgets/app_staggered_fade.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _batchAlerts = true;
  bool _orderAlerts = true;
  bool _providerAlerts = false;

  final Set<String> _followedProviderIds = {
    'ainSebaa',
    'centre',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<OrderProvider>().loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<AppSettingsProvider>();
    final orders = context.watch<OrderProvider>().orders;

    final userName = auth.user?.name ?? l10n.profileDefaultName;
    final userEmail = auth.user?.email ?? l10n.profileDefaultEmail;
    final localeLabel = settings.locale.languageCode == 'fr' ? l10n.french : l10n.english;
    final themeLabel = settings.themeMode == ThemeMode.dark ? l10n.dark : l10n.light;
    final totalOrders = orders.length;
    final completedOrders = orders.where((order) => order.status == OrderStatus.completed).length;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile)),
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
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            child: Text(
                              _initials(userName),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: AppSpacing.xxs),
                                Text(
                                  userEmail,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.profileSubtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: [
                          Chip(label: Text(l10n.mvpBadge)),
                          Chip(label: Text(localeLabel)),
                          Chip(label: Text(themeLabel)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppStaggeredFade(
              index: 1,
              child: Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: l10n.myOrders,
                      value: totalOrders.toString(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _MetricCard(
                      label: l10n.orderStatusCompleted,
                      value: completedOrders.toString(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _MetricCard(
                      label: l10n.providerPreferences,
                      value: _followedProviderIds.length.toString(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppStaggeredFade(
              index: 2,
              child: Card(
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
                      Text(
                        l10n.profileOrdersSubtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.receipt_long_outlined),
                        title: Text(l10n.myOrders),
                        subtitle: Text(l10n.profileOrdersSubtitle),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MyOrdersScreen(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.tune_rounded),
                        title: Text(l10n.openSettings),
                        subtitle: Text(l10n.profileNotificationsSubtitle),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.settings);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppStaggeredFade(
              index: 3,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.appPreferences,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.profileLanguageSubtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
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
                          context.read<AppSettingsProvider>().setLocale(Locale(value.first));
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.switchTheme),
                        subtitle: Text(l10n.profileThemeSubtitle),
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
            const SizedBox(height: AppSpacing.md),
            AppStaggeredFade(
              index: 4,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.providerPreferences,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.providerPreferencesSubtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: [
                          FilterChip(
                            selected: _followedProviderIds.contains('ainSebaa'),
                            label: Text(l10n.providerAinSebaa),
                            onSelected: (selected) => setState(() {
                              _toggleProvider('ainSebaa', selected);
                            }),
                          ),
                          FilterChip(
                            selected: _followedProviderIds.contains('centre'),
                            label: Text(l10n.providerCentre),
                            onSelected: (selected) => setState(() {
                              _toggleProvider('centre', selected);
                            }),
                          ),
                          FilterChip(
                            selected: _followedProviderIds.contains('east'),
                            label: Text(l10n.providerEast),
                            onSelected: (selected) => setState(() {
                              _toggleProvider('east', selected);
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppStaggeredFade(
              index: 5,
              child: Card(
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
                      Text(
                        l10n.profileNotificationsSubtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.notifications_none_rounded),
                        title: Text(l10n.notificationsPreferences),
                        subtitle: Text(l10n.notificationsScreenSubtitle),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.notifications);
                        },
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.batchAlerts),
                        subtitle: Text(l10n.batchAlertsSubtitle),
                        value: _batchAlerts,
                        onChanged: (value) => setState(() => _batchAlerts = value),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.orderAlerts),
                        subtitle: Text(l10n.orderAlertsSubtitle),
                        value: _orderAlerts,
                        onChanged: (value) => setState(() => _orderAlerts = value),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.providerAlerts),
                        subtitle: Text(l10n.providerAlertsSubtitle),
                        value: _providerAlerts,
                        onChanged: (value) => setState(() => _providerAlerts = value),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppStaggeredFade(
              index: 6,
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

  void _toggleProvider(String providerId, bool selected) {
    if (selected) {
      _followedProviderIds.add(providerId);
    } else {
      _followedProviderIds.remove(providerId);
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return 'B';
    }

    final buffer = StringBuffer();
    for (final part in parts.take(2)) {
      if (part.isNotEmpty) {
        buffer.write(part[0].toUpperCase());
      }
    }

    final initials = buffer.toString();
    return initials.isEmpty ? 'B' : initials;
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      color: scheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}