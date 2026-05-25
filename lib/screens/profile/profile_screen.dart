/// ============================================================================
/// [ProfileScreen] - User account dashboard and preferences
/// ============================================================================
/// StatefulWidget displaying authenticated user's profile, order history, and
/// app preferences. Provides navigation to settings and My Batches screens.
///
/// Responsibilities:
/// - Display user identity (name, email, initials avatar)
/// - Show order metrics (total orders, completed orders)
/// - Display current app settings (theme, locale)
/// - Provide navigation to My Batches order list
/// - Provide navigation to Settings screen
/// - Manage followed/subscribed provider list (local state)
/// - Display provider preferences (FilterChips for subscribed providers)
/// - Handle logout action via AuthProvider
///
/// State:
/// - _followedProviderIds: Set of provider IDs user is subscribed to
/// - Watches AuthProvider for user identity
/// - Watches AppSettingsProvider for theme/locale
/// - Watches OrderProvider for order metrics
///
/// Architecture:
/// - Orders loaded on mount (addPostFrameCallback)
/// - UI reflects settings reactively via Provider consumers
/// - Logout navigates back to splash screen via AppRoutes
/// ============================================================================
import 'package:batchit/core/app_routes.dart';
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/providers/provider_provider.dart';
import 'package:batchit/models/order.dart';
import 'package:batchit/models/provider_profile.dart';
import 'package:batchit/providers/app_settings_provider.dart';
import 'package:batchit/providers/auth_provider.dart';
import 'package:batchit/providers/order_provider.dart';
import 'package:batchit/services/provider_service.dart';

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

/// Manages profile screen state including followed provider set.
class _ProfileScreenState extends State<ProfileScreen> {
  final ProviderService _providerService = ProviderService();
  List<ProviderProfile> _followedProviders = [];
  bool _loadingProviders = true;

  /// Loads user orders on first render for metrics display.
  /// Safe check: verifies mounted before using context.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<OrderProvider>().loadOrders();
      context.read<ProviderProvider>().loadMyProfile();
      _loadFollowedProviders();
    });
  }

  Future<void> _loadFollowedProviders() async {
    final providers = await _providerService.fetchFollowedProviders();
    if (!mounted) return;
    setState(() {
      _followedProviders = providers;
      _loadingProviders = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<AppSettingsProvider>();
    final orders = context.watch<OrderProvider>().orders;

    final userName = auth.user?.displayName ?? l10n.profileDefaultName;
    final userEmail = auth.user?.email ?? l10n.profileDefaultEmail;
    final avatarUrl = auth.user?.avatarUrl;
    final localeLabel = settings.locale.languageCode == 'fr' ? l10n.french : l10n.english;
    final themeLabel = settings.themeMode == ThemeMode.dark ? l10n.dark : l10n.light;
    final totalOrders = orders.length;
    final completedOrders = orders.where((order) => order.status == OrderStatus.completed).length;
    final followedCount = _followedProviders.length;

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
                            backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                                ? NetworkImage(avatarUrl)
                                : null,
                            child: avatarUrl != null && avatarUrl.isNotEmpty
                                ? null
                                : Text(
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
                            IconButton(
                              onPressed: () {
                                Navigator.pushNamed(context, AppRoutes.profileEdit);
                              },
                              icon: const Icon(Icons.edit_rounded),
                              tooltip: l10n.profileEditTitle,
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
                          value: _loadingProviders ? '...' : followedCount.toString(),
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
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.myBatches,
                        ),
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
                      _BecomeProviderTile(l10n: l10n),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.people_rounded),
                        title: const Text('About Us'),
                        subtitle: const Text('Meet the team behind BatchIt'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => Navigator.pushNamed(context, AppRoutes.aboutUs),
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
                      if (_loadingProviders)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                          child: LinearProgressIndicator(),
                        )
                      else if (_followedProviders.isEmpty)
                        Text(
                          l10n.providerPreferencesSubtitle,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        )
                      else
                        Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: _followedProviders.map((provider) {
                            return ActionChip(
                              avatar: provider.logoUrl != null && provider.logoUrl!.isNotEmpty
                                  ? CircleAvatar(
                                      backgroundImage: NetworkImage(provider.logoUrl!),
                                      radius: 10,
                                    )
                                  : const Icon(Icons.storefront_rounded, size: 18),
                              label: Text(provider.businessName),
                              onPressed: () => Navigator.pushNamed(
                                context,
                                AppRoutes.providerDetail,
                                arguments: provider.id,
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppStaggeredFade(
              index: 4,
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: auth.isLoading
                      ? null
                      : () async {
                          await context.read<AuthProvider>().logout();
                          if (context.mounted) {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.splashscreen,
                            );
                          }
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    backgroundColor: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.18),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.error.withValues(alpha: 0.45),
                    ),
                  ),
                  icon: const Icon(Icons.logout_rounded),
                  label: auth.isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.logout),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

class _BecomeProviderTile extends StatelessWidget {
  const _BecomeProviderTile({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final myProfile = context.watch<ProviderProvider>().myProfile;
    final scheme = Theme.of(context).colorScheme;

    final (icon, label, subtitle) = myProfile == null
        ? (
            Icons.storefront_rounded,
            l10n.becomeProvider,
            l10n.providerStep1Subtitle,
          )
        : myProfile.isVerified
            ? (
                Icons.verified_rounded,
                'My Provider Profile',
                myProfile.businessName,
              )
            : (
                Icons.hourglass_top_rounded,
                'My Provider Profile',
                myProfile.businessName,
              );

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon,
          color: myProfile?.isVerified == true ? Colors.green : scheme.primary),
      title: Text(label),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => Navigator.pushNamed(context, AppRoutes.becomeProvider),
    );
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