import 'package:batchit/core/app_routes.dart';
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/models/batch.dart';
import 'package:batchit/providers/batch_provider.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:batchit/widgets/app_screen_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum _SearchMode { batches, providers }

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  _SearchMode _searchMode = _SearchMode.batches;
  String _query = '';

  static const List<_ProviderResult> _providerResults = [
    _ProviderResult(name: 'Hub Ain Sebaa', category: 'Groceries', location: 'Ain Sebaa', subscribers: 284),
    _ProviderResult(name: 'Hub Centre', category: 'Household', location: 'Centre', subscribers: 196),
    _ProviderResult(name: 'Hub East', category: 'Groceries', location: 'East', subscribers: 152),
    _ProviderResult(name: 'Carrefour', category: 'Groceries', location: 'Citywide', subscribers: 401),
    _ProviderResult(name: 'Marjane', category: 'Household', location: 'Citywide', subscribers: 367),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<BatchProvider>();
      if (provider.batches.isEmpty) {
        provider.loadNearbyBatches();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final batches = context.watch<BatchProvider>().batches;

    final filteredBatches = _filterBatches(batches, _query);
    final filteredProviders = _filterProviders(_providerResults, _query);

    final showingBatches = _searchMode == _SearchMode.batches;
    final hasResults = showingBatches ? filteredBatches.isNotEmpty : filteredProviders.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.search)),
      body: AppScreenContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: (value) => setState(() => _query = value.trim()),
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<_SearchMode>(
              segments: [
                ButtonSegment<_SearchMode>(
                  value: _SearchMode.batches,
                  label: Text(l10n.searchModeBatches),
                  icon: const Icon(Icons.inventory_2_outlined),
                ),
                ButtonSegment<_SearchMode>(
                  value: _SearchMode.providers,
                  label: Text(l10n.searchModeProviders),
                  icon: const Icon(Icons.storefront_outlined),
                ),
              ],
              selected: {_searchMode},
              onSelectionChanged: (value) => setState(() => _searchMode = value.first),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: !hasResults
                  ? _EmptySearchState(message: l10n.noSearchResults)
                  : showingBatches
                      ? ListView.separated(
                          itemCount: filteredBatches.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            final batch = filteredBatches[index];
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: scheme.primaryContainer,
                                  child: Icon(Icons.inventory_2_outlined, color: scheme.onPrimaryContainer),
                                ),
                                title: Text(batch.productName),
                                subtitle: Text('${batch.locationName} • ${batch.hubName}'),
                                trailing: const Icon(Icons.chevron_right_rounded),
                                onTap: () {
                                  Navigator.pushNamed(context, AppRoutes.batchDetails, arguments: batch.id);
                                },
                              ),
                            );
                          },
                        )
                      : ListView.separated(
                          itemCount: filteredProviders.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            final provider = filteredProviders[index];
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: scheme.secondaryContainer,
                                  child: Icon(Icons.storefront_outlined, color: scheme.onSecondaryContainer),
                                ),
                                title: Text(provider.name),
                                subtitle: Text('${provider.category} • ${provider.location}'),
                                trailing: Text('${provider.subscribers}'),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  List<Batch> _filterBatches(List<Batch> batches, String query) {
    if (query.isEmpty) return batches;
    final q = query.toLowerCase();

    return batches.where((batch) {
      return batch.productName.toLowerCase().contains(q) ||
          batch.locationName.toLowerCase().contains(q) ||
          batch.hubName.toLowerCase().contains(q);
    }).toList(growable: false);
  }

  List<_ProviderResult> _filterProviders(List<_ProviderResult> providers, String query) {
    if (query.isEmpty) return providers;
    final q = query.toLowerCase();

    return providers.where((provider) {
      return provider.name.toLowerCase().contains(q) ||
          provider.category.toLowerCase().contains(q) ||
          provider.location.toLowerCase().contains(q);
    }).toList(growable: false);
  }
}

class _ProviderResult {
  const _ProviderResult({
    required this.name,
    required this.category,
    required this.location,
    required this.subscribers,
  });

  final String name;
  final String category;
  final String location;
  final int subscribers;
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 56,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
