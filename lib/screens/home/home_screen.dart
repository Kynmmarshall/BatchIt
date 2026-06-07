// ============================================================================
// [HomeScreen] - Main dashboard for browsing and discovering batches
// ============================================================================
// StatefulWidget that displays a personalized dashboard with:
// - Welcome header with quick notification button
// - Tappable search box that navigates to SearchResultsScreen
// - Quick stats (active batches count, open batches count)
// - Active batches carousel (top 3 batches)
// - Filter chips to view all/open/full batches
// - Full list of filtered batches with cards and progress indicators
//
// Responsibilities:
// - Load nearby batches on mount (via addPostFrameCallback)
// - Apply local filter to batch list based on user selection
// - Render gradient hero header with MetaCh brand messaging
// - Display batch cards with tap -> batch details navigation
// - Provide batch info summary (progress %, join button, etc.)
//
// State:
// - _selectedFilter: Current view (nearby/open/full) - default nearby
// - Watches BatchProvider for batches list and loading state
// - Uses AppLocalizations for EN/FR text labels
// ============================================================================
import 'package:batchit/core/app_routes.dart';
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/models/batch.dart';
import 'package:batchit/providers/batch_provider.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:batchit/widgets/batch_card.dart';
import 'package:batchit/widgets/app_screen_container.dart';
import 'package:batchit/widgets/app_staggered_fade.dart';
import 'package:batchit/widgets/distance_filter_bar.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

/// Private filter enum for home screen batch visibility modes.
enum _BatchFilter { nearby, open, full }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// Manages home screen state including filter selection and distance filtering.
class _HomeScreenState extends State<HomeScreen> {
  _BatchFilter _selectedFilter = _BatchFilter.nearby;
  double _distanceKm = 20.0;
  Position? _currentPosition;
  bool _distanceFilterEnabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentLocation();
      if (mounted) context.read<BatchProvider>().loadNearbyBatches();
    });
  }

  Future<void> _loadCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() => _currentPosition = position);

      if (!mounted) { return; }
      context.read<BatchProvider>().loadNearbyBatches(
        latitude: position.latitude,
        longitude: position.longitude,
        radiusKm: _distanceKm,
      );
    } catch (_) {}
  }

  void _toggleDistanceFilter() {
    setState(() => _distanceFilterEnabled = !_distanceFilterEnabled);
    _reloadWithDistance();
  }

  void _reloadWithDistance() {
    final pos = _currentPosition;
    if (_distanceFilterEnabled && pos != null) {
      context.read<BatchProvider>().loadNearbyBatches(
        latitude: pos.latitude,
        longitude: pos.longitude,
        radiusKm: _distanceKm,
      );
    } else {
      context.read<BatchProvider>().loadNearbyBatches();
    }
  }

  /// Filters batch list based on selected filter criteria.
  /// Returns the complete list for 'nearby' mode.
  /// Returns only batches that can still be joined for 'open' mode.
  /// Returns only full batches (isFull) for 'full' mode.
  List<Batch> _applyFilter(List<Batch> batches) {
    switch (_selectedFilter) {
      case _BatchFilter.open:
        return batches.where((batch) => batch.canJoin).toList();
      case _BatchFilter.full:
        return batches.where((batch) => batch.isFull).toList();
      case _BatchFilter.nearby:
        return batches;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final batchProvider = context.watch<BatchProvider>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final filteredBatches = _applyFilter(batchProvider.batches);

    final filters = <(_BatchFilter, String)>[
      (_BatchFilter.nearby, l10n.nearbyBatches),
      (_BatchFilter.open, l10n.open),
      (_BatchFilter.full, l10n.full),
    ];
    final activeBatches = batchProvider.batches.take(3).toList(growable: false);
    final openCount = batchProvider.batches.where((batch) => batch.canJoin).length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppScreenContainer(
        child: ListView(
            children: [
              AppStaggeredFade(
                index: 0,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        scheme.primary.withValues(alpha: 0.12),
                        scheme.secondaryContainer.withValues(alpha: 0.78),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.home,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: scheme.onSurface,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.dashboardSubtitle,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: scheme.surface.withValues(alpha: 0.8),
                              shape: BoxShape.circle,
                              border: Border.all(color: scheme.outlineVariant),
                            ),
                            child: IconButton(
                              onPressed: () {
                                Navigator.pushNamed(context, AppRoutes.notifications);
                              },
                              icon: Icon(
                                Icons.notifications_none_rounded,
                                color: scheme.onSurface,
                              ),
                              tooltip: l10n.notificationsPreferences,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => Navigator.pushNamed(context, AppRoutes.search),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: scheme.surface.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: scheme.outlineVariant),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.search_rounded, color: scheme.onSurfaceVariant),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    l10n.searchHint,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Icon(Icons.tune_rounded, color: scheme.onSurfaceVariant),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _DashboardStat(
                              label: l10n.activeBatches,
                              value: batchProvider.batches.length.toString(),
                              scheme: scheme,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _DashboardStat(
                              label: l10n.open,
                              value: openCount.toString(),
                              scheme: scheme,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Text(
                    l10n.activeBatches,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 290,
                child: batchProvider.isLoading
                    ? Center(
                        child: CircularProgressIndicator(color: scheme.primary),
                      )
                    : activeBatches.isEmpty
                        ? _EmptyDashboardState(
                            message: l10n.noBatchesForFilter,
                            scheme: scheme,
                          )
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: activeBatches.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final batch = activeBatches[index];
                              return SizedBox(
                                width: 220,
                                child: AppStaggeredFade(
                                  index: index + 1,
                                  beginOffset: const Offset(0.04, 0),
                                  child: BatchCard(
                                    batch: batch,
                                    joinLabel: l10n.join,
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.batchDetails,
                                        arguments: batch.id,
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 46,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final (filter, label) = filters[index];
                    final selected = filter == _selectedFilter;

                    return AppStaggeredFade(
                      index: index + 1,
                      child: ChoiceChip(
                        showCheckmark: false,
                        label: Text(label),
                        selected: selected,
                        onSelected: (_) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                        labelStyle: theme.textTheme.titleMedium?.copyWith(
                          color: selected ? scheme.onPrimary : scheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                        selectedColor: scheme.primary,
                        backgroundColor: scheme.surfaceContainerHighest,
                        side: BorderSide(
                          color: selected ? scheme.primary : scheme.outlineVariant,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    _distanceFilterEnabled
                        ? Icons.near_me_rounded
                        : Icons.near_me_disabled,
                    size: 15,
                    color: _distanceFilterEnabled
                        ? scheme.primary
                        : scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Distance filter',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _distanceFilterEnabled
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _toggleDistanceFilter,
                    child: Icon(
                      _distanceFilterEnabled
                          ? Icons.toggle_on_rounded
                          : Icons.toggle_off_rounded,
                      size: 32,
                      color: _distanceFilterEnabled
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (_distanceFilterEnabled) ...[
                const SizedBox(height: 8),
                DistanceFilterBar(
                  value: _distanceKm,
                  hasLocation: _currentPosition != null,
                  onChanged: (v) => setState(() => _distanceKm = v),
                  onChangeEnd: (v) {
                    setState(() => _distanceKm = v);
                    _reloadWithDistance();
                  },
                ),
              ],
              const SizedBox(height: 22),
              Row(
                children: [
                  Text(
                    l10n.popularBatches,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              batchProvider.isLoading
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: CircularProgressIndicator(color: scheme.primary),
                      ),
                    )
                  : filteredBatches.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              l10n.noBatchesForFilter,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: AppSpacing.sm,
                                crossAxisSpacing: AppSpacing.sm,
                                childAspectRatio: 0.82,
                              ),
                          itemCount: filteredBatches.length,
                          itemBuilder: (context, index) {
                            final batch = filteredBatches[index];
                            return AppStaggeredFade(
                              index: index + 4,
                              beginOffset: const Offset(0, 0.05),
                              child: BatchCard(
                                batch: batch,
                                joinLabel: l10n.join,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.batchDetails,
                                    arguments: batch.id,
                                  );
                                },
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),

    );
  }
}

class _DashboardStat extends StatelessWidget {
  const _DashboardStat({
    required this.label,
    required this.value,
    required this.scheme,
  });

  final String label;
  final String value;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyDashboardState extends StatelessWidget {
  const _EmptyDashboardState({required this.message, required this.scheme});

  final String message;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}
