import 'package:batchit/core/app_routes.dart';
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/models/provider_profile.dart';
import 'package:batchit/providers/provider_provider.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:batchit/widgets/app_screen_container.dart';
import 'package:batchit/widgets/app_staggered_fade.dart';
import 'package:batchit/widgets/provider_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProviderDiscoveryScreen extends StatefulWidget {
  const ProviderDiscoveryScreen({super.key});

  @override
  State<ProviderDiscoveryScreen> createState() =>
      _ProviderDiscoveryScreenState();
}

class _ProviderDiscoveryScreenState extends State<ProviderDiscoveryScreen> {
  // null means "All"
  BusinessCategory? _selectedCategory;
  String _query = '';
  final Set<String> _followedIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ProviderProvider>().loadVerifiedProviders();
    });
  }

  List<ProviderProfile> _filter(List<ProviderProfile> all) {
    return all.where((p) {
      if (_selectedCategory != null && p.category != _selectedCategory) {
        return false;
      }
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return p.businessName.toLowerCase().contains(q) ||
          p.ownerName.toLowerCase().contains(q) ||
          p.address.toLowerCase().contains(q);
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = context.watch<ProviderProvider>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final filtered = _filter(state.verifiedProviders);
    final hasProviders = state.verifiedProviders.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.providersVerifiedTitle)),
      body: AppScreenContainer(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  // ── Header card ──────────────────────────────────────────
                  AppStaggeredFade(
                    index: 0,
                    child: _HeaderBanner(l10n: l10n, scheme: scheme, theme: theme),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // ── Search + filter ──────────────────────────────────────
                  AppStaggeredFade(
                    index: 1,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              onChanged: (v) =>
                                  setState(() => _query = v.trim()),
                              decoration: InputDecoration(
                                hintText: l10n.searchHint,
                                prefixIcon:
                                    const Icon(Icons.search_rounded),
                                isDense: true,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _CategoryFilterBar(
                              selected: _selectedCategory,
                              onChanged: (cat) =>
                                  setState(() => _selectedCategory = cat),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // ── Provider list ────────────────────────────────────────
                  if (!hasProviders)
                    AppStaggeredFade(
                      index: 2,
                      child: _EmptyState(
                        icon: Icons.storefront_outlined,
                        title: l10n.providerNoVerified,
                        subtitle: l10n.providerNoVerifiedSubtitle,
                      ),
                    )
                  else if (filtered.isEmpty)
                    AppStaggeredFade(
                      index: 2,
                      child: _EmptyState(
                        icon: Icons.search_off_rounded,
                        title: l10n.providerNoResults,
                        subtitle: l10n.providerNoResultsSubtitle,
                      ),
                    )
                  else
                    ...filtered.asMap().entries.map((entry) {
                      final i = entry.key;
                      final provider = entry.value;
                      return AppStaggeredFade(
                        index: i + 2,
                        child: Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: ProviderCard(
                            provider: provider,
                            isFollowing:
                                _followedIds.contains(provider.id),
                            onFollowToggle: () => setState(() {
                              if (_followedIds.contains(provider.id)) {
                                _followedIds.remove(provider.id);
                              } else {
                                _followedIds.add(provider.id);
                              }
                            }),
                          ),
                        ),
                      );
                    }),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
      ),
    );
  }
}

// ─── Header banner ────────────────────────────────────────────────────────────

class _HeaderBanner extends StatelessWidget {
  const _HeaderBanner({
    required this.l10n,
    required this.scheme,
    required this.theme,
  });

  final AppLocalizations l10n;
  final ColorScheme scheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary.withValues(alpha: 0.15),
            scheme.secondaryContainer.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.providersVerifiedTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  l10n.providersScreenLead,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          FilledButton.icon(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.becomeProvider),
            icon: const Icon(Icons.add_business_rounded, size: 18),
            label: Text(
              l10n.createProviderProfile,
              style: theme.textTheme.labelSmall,
            ),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Category filter bar ──────────────────────────────────────────────────────

class _CategoryFilterBar extends StatelessWidget {
  const _CategoryFilterBar({required this.selected, required this.onChanged});

  final BusinessCategory? selected;
  final ValueChanged<BusinessCategory?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final options = <(BusinessCategory?, String)>[
      (null, l10n.seeAll),
      (BusinessCategory.grocery, l10n.providerCategoryGrocery),
      (BusinessCategory.household, l10n.providerCategoryHousehold),
      (BusinessCategory.restaurant, l10n.providerCategoryRestaurant),
      (BusinessCategory.electronics, l10n.providerCategoryElectronics),
      (BusinessCategory.clothing, l10n.providerCategoryClothing),
      (BusinessCategory.other, l10n.providerCategoryOther),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((opt) {
          final (cat, label) = opt;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: FilterChip(
              label: Text(label),
              selected: selected == cat,
              onSelected: (_) => onChanged(cat),
              visualDensity: VisualDensity.compact,
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: scheme.outlineVariant),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
