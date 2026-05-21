import 'package:batchit/core/app_routes.dart';
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/models/provider_profile.dart';
import 'package:batchit/providers/provider_provider.dart';
import 'package:batchit/themes/app_spacing.dart';
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: theme.brightness == Brightness.dark
                ? [const Color(0xFF1a1a1a), const Color(0xFF0d0d0d)]
                : [const Color(0xFFFafafa), const Color(0xFFF5f5f5)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    children: [
                      // Header banner
                      _buildHeaderBanner(l10n, scheme, theme),
                      const SizedBox(height: AppSpacing.sm),

                      // Search and filter card
                      _buildSearchCard(l10n),
                      const SizedBox(height: AppSpacing.sm),

                      // Provider list or empty state
                      if (!hasProviders)
                        _buildEmptyState(
                          l10n.providerNoVerified,
                          l10n.providerNoVerifiedSubtitle,
                          Icons.storefront_outlined,
                          theme,
                          scheme,
                        )
                      else if (filtered.isEmpty)
                        _buildEmptyState(
                          l10n.providerNoResults,
                          l10n.providerNoResultsSubtitle,
                          Icons.search_off_rounded,
                          theme,
                          scheme,
                        )
                      else
                        ...filtered.map((provider) {
                          return Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: ProviderCard(
                              provider: provider,
                              isFollowing: _followedIds.contains(provider.id),
                              onFollowToggle: () => setState(() {
                                if (_followedIds.contains(provider.id)) {
                                  _followedIds.remove(provider.id);
                                } else {
                                  _followedIds.add(provider.id);
                                }
                              }),
                            ),
                          );
                        }),

                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBanner(
    AppLocalizations l10n,
    ColorScheme scheme,
    ThemeData theme,
  ) {
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
          // Fix: wrap the button in a SizedBox to prevent infinite width
          // caused by the Row's Expanded child giving non‑flexible children
          // unbounded horizontal constraints.
          SizedBox(
            width: 150, // Adjust as needed to fit the label
            child: FilledButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.becomeProvider),
              icon: const Icon(Icons.add_business_rounded, size: 18),
              label: Text(
                l10n.createProviderProfile,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCard(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              onChanged: (v) => setState(() => _query = v.trim()),
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search_rounded),
                isDense: true,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildCategoryFilter(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(AppLocalizations l10n) {
    final options = <(BusinessCategory?, String)>[
      (null, l10n.seeAll),
      (BusinessCategory.grocery, l10n.providerCategoryGrocery),
      (BusinessCategory.household, l10n.providerCategoryHousehold),
      (BusinessCategory.restaurant, l10n.providerCategoryRestaurant),
      (BusinessCategory.electronics, l10n.providerCategoryElectronics),
      (BusinessCategory.clothing, l10n.providerCategoryClothing),
      (BusinessCategory.other, l10n.providerCategoryOther),
    ];

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: options.map((opt) {
        final (cat, label) = opt;
        return FilterChip(
          label: Text(label),
          selected: _selectedCategory == cat,
          onSelected: (_) => setState(() => _selectedCategory = cat),
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(
    String title,
    String subtitle,
    IconData icon,
    ThemeData theme,
    ColorScheme scheme,
  ) {
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