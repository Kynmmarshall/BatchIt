/// ============================================================================
/// [SearchResultsScreen] - Unified search interface for batches and providers
/// ============================================================================
/// StatefulWidget that provides a dual-mode search experience:
/// - "Batches" mode: Search batches by product, location, hub name
/// - "Providers" mode: Search providers by name, category, location
///
/// Responsibilities:
/// - Render search input field and mode toggle (SegmentedButton)
/// - Filter results in real-time based on query text
/// - Display results as scrollable ListView with tap-to-navigate
/// - Show empty state if no results match query
/// - Load nearby batches on mount (if not cached)
/// - Switch between batch/provider result views
///
/// State:
/// - _searchMode: Current view mode (batches or providers)
/// - _query: User search input text (trimmed)
/// - Watches BatchProvider for live batches list
/// - _providerResults: Verified providers fetched from backend
///
/// Architecture:
/// - Search filtering is local/client-side (no backend search API yet)
/// - Results update immediately as user types (reactive)
/// - Empty state shown when no results match current mode + query
/// ============================================================================
import 'package:batchit/core/app_routes.dart';
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/models/batch.dart';
import 'package:batchit/models/provider_profile.dart';
import 'package:batchit/providers/batch_provider.dart';
import 'package:batchit/services/provider_service.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:batchit/widgets/app_screen_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Private enum for search result modes.
enum _SearchMode { batches, providers }

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

/// Manages search state including query text and mode selection.
class _SearchResultsScreenState extends State<SearchResultsScreen> {
  _SearchMode _searchMode = _SearchMode.batches;
  String _query = '';
  final ProviderService _providerService = ProviderService();
  List<ProviderProfile> _providerResults = const [];

  /// Ensures nearby batches are loaded on first render.
  /// Checks if BatchProvider already has batches to avoid redundant fetch.
  /// Safe check: verifies mounted before using context.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<BatchProvider>();
      if (provider.batches.isEmpty) {
        provider.loadNearbyBatches();
      }
      _loadProviders();
    });
  }

  Future<void> _loadProviders() async {
    final providers = await _providerService.fetchVerifiedProviders();
    if (!mounted) return;
    setState(() => _providerResults = providers);
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
                                  backgroundImage: provider.logoUrl != null
                                      ? NetworkImage(provider.logoUrl!)
                                      : null,
                                  child: provider.logoUrl == null
                                      ? Icon(Icons.storefront_outlined, color: scheme.onSecondaryContainer)
                                      : null,
                                ),
                                title: Text(provider.businessName),
                                subtitle: Text('${provider.category.name} • ${provider.address}'),
                                trailing: provider.isVerified
                                    ? Icon(Icons.verified_rounded, color: scheme.primary)
                                    : null,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.providerDetail,
                                  arguments: provider.id,
                                ),
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

  /// Filters batch list based on query string (case-insensitive).
  /// Searches across productName, locationName, and hubName fields.
  /// Returns empty list if query matches nothing.
  List<Batch> _filterBatches(List<Batch> batches, String query) {
    if (query.isEmpty) return batches;
    final q = query.toLowerCase();

    return batches.where((batch) {
      return batch.productName.toLowerCase().contains(q) ||
          batch.locationName.toLowerCase().contains(q) ||
          batch.hubName.toLowerCase().contains(q);
    }).toList(growable: false);
  }

  /// Filters provider list based on query string (case-insensitive).
  /// Searches across business name, category, and address fields.
  /// Returns empty list if query matches nothing.
  List<ProviderProfile> _filterProviders(List<ProviderProfile> providers, String query) {
    if (query.isEmpty) return providers;
    final q = query.toLowerCase();

    return providers.where((provider) {
      return provider.businessName.toLowerCase().contains(q) ||
          provider.category.name.toLowerCase().contains(q) ||
          provider.address.toLowerCase().contains(q);
    }).toList(growable: false);
  }
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
