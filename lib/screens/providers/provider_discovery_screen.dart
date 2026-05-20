/// ============================================================================
/// [ProviderDiscoveryScreen] - Browse and discover marketplace providers
/// ============================================================================
/// StatefulWidget for discovering, filtering, and subscribing to providers.
/// Provides category-based filtering (All/Groceries/Household/Snacks) and
/// search functionality across provider name and location.
///
/// Responsibilities:
/// - Display all available providers (groceries, households, snacks)
/// - Filter by category via FilterChip selection
/// - Filter by search query (name/location text match)
/// - Show provider cards with name, category, location, rating, subscribers
/// - Track subscribed providers in local state (_subscribedProviderIds)
/// - Handle subscribe/unsubscribe button taps (toggle subscription)
/// - Persist subscription state (TODO: backend sync)
///
/// State:
/// - _selectedCategory: Active filter (all/groceries/household/snacks)
/// - _query: Search input text (empty = show all)
/// - _subscribedProviderIds: Set of IDs user is subscribed to
/// - Static _providers: Mock provider data (TODO: backend API)
///
/// Architecture:
/// - Filter logic is client-side (all providers always fetched)
/// - Search is case-insensitive substring match
/// - Subscription state is local (no backend sync yet)
/// - Layout uses ListView + Card for scrollable provider list
/// ============================================================================
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:batchit/widgets/app_screen_container.dart';
import 'package:flutter/material.dart';

/// Private enum for provider category filters.
enum _ProviderCategory { all, groceries, household, snacks }

class ProviderDiscoveryScreen extends StatefulWidget {
  const ProviderDiscoveryScreen({super.key});

  @override
  State<ProviderDiscoveryScreen> createState() => _ProviderDiscoveryScreenState();
}

/// Manages provider discovery state including category filter and search.
class _ProviderDiscoveryScreenState extends State<ProviderDiscoveryScreen> {
  _ProviderCategory _selectedCategory = _ProviderCategory.all;
  String _query = '';

  final Set<String> _subscribedProviderIds = {'hub-ain-sebaa', 'carrefour'};

  static const List<_ProviderItem> _providers = [
    _ProviderItem(
      id: 'hub-ain-sebaa',
      name: 'Hub Ain Sebaa',
      category: _ProviderCategory.groceries,
      location: 'Ain Sebaa',
      subscribers: 284,
      rating: 4.8,
    ),
    _ProviderItem(
      id: 'hub-centre',
      name: 'Hub Centre',
      category: _ProviderCategory.household,
      location: 'Centre',
      subscribers: 196,
      rating: 4.6,
    ),
    _ProviderItem(
      id: 'hub-east',
      name: 'Hub East',
      category: _ProviderCategory.groceries,
      location: 'East',
      subscribers: 152,
      rating: 4.5,
    ),
    _ProviderItem(
      id: 'carrefour',
      name: 'Carrefour',
      category: _ProviderCategory.groceries,
      location: 'Citywide',
      subscribers: 401,
      rating: 4.7,
    ),
    _ProviderItem(
      id: 'marjane',
      name: 'Marjane',
      category: _ProviderCategory.household,
      location: 'Citywide',
      subscribers: 367,
      rating: 4.4,
    ),
    _ProviderItem(
      id: 'snack-world',
      name: 'Snack World',
      category: _ProviderCategory.snacks,
      location: 'Downtown',
      subscribers: 128,
      rating: 4.3,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    final filteredProviders = _providers.where((provider) {
      final matchesCategory = _selectedCategory == _ProviderCategory.all || provider.category == _selectedCategory;
      if (!matchesCategory) return false;

      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return provider.name.toLowerCase().contains(q) || provider.location.toLowerCase().contains(q);
    }).toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.providerDiscovery)),
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
                      l10n.providerDiscovery,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.providerDiscoverySubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      onChanged: (value) => setState(() => _query = value.trim()),
                      decoration: InputDecoration(
                        hintText: l10n.searchHint,
                        prefixIcon: const Icon(Icons.search_rounded),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        FilterChip(
                          selected: _selectedCategory == _ProviderCategory.all,
                          label: Text(l10n.seeAll),
                          onSelected: (_) => setState(() => _selectedCategory = _ProviderCategory.all),
                        ),
                        FilterChip(
                          selected: _selectedCategory == _ProviderCategory.groceries,
                          label: Text(l10n.questionnaireChipGroceries),
                          onSelected: (_) => setState(() => _selectedCategory = _ProviderCategory.groceries),
                        ),
                        FilterChip(
                          selected: _selectedCategory == _ProviderCategory.household,
                          label: Text(l10n.questionnaireChipHousehold),
                          onSelected: (_) => setState(() => _selectedCategory = _ProviderCategory.household),
                        ),
                        FilterChip(
                          selected: _selectedCategory == _ProviderCategory.snacks,
                          label: Text(l10n.questionnaireChipSnacks),
                          onSelected: (_) => setState(() => _selectedCategory = _ProviderCategory.snacks),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (filteredProviders.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Center(
                  child: Text(
                    l10n.noSearchResults,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              )
            else
              ...filteredProviders.map((provider) {
                final subscribed = _subscribedProviderIds.contains(provider.id);

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: scheme.secondaryContainer,
                        child: Icon(
                          Icons.storefront_outlined,
                          color: scheme.onSecondaryContainer,
                        ),
                      ),
                      title: Text(provider.name),
                      subtitle: Text('${provider.location} • ${provider.subscribers} subscribers • ${provider.rating.toStringAsFixed(1)}★'),
                      trailing: FilledButton.tonal(
                        onPressed: () {
                          setState(() {
                            if (subscribed) {
                              _subscribedProviderIds.remove(provider.id);
                            } else {
                              _subscribedProviderIds.add(provider.id);
                            }
                          });
                        },
                        child: Text(subscribed ? 'Subscribed' : 'Subscribe'),
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _ProviderItem {
  const _ProviderItem({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.subscribers,
    required this.rating,
  });

  final String id;
  final String name;
  final _ProviderCategory category;
  final String location;
  final int subscribers;
  final double rating;
}
