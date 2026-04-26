import 'package:batchit/core/app_routes.dart';
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/models/batch.dart';
import 'package:batchit/providers/batch_provider.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:batchit/widgets/batch_card.dart';
import 'package:batchit/widgets/app_staggered_fade.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum _BatchFilter { nearby, open, full }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  _BatchFilter _selectedFilter = _BatchFilter.nearby;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BatchProvider>().loadNearbyBatches();
    });
  }

  List<Batch> _applyFilter(List<Batch> batches) {
    switch (_selectedFilter) {
      case _BatchFilter.open:
        return batches.where((batch) => !batch.isFull).toList();
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
      (_BatchFilter.open, 'Open'),
      (_BatchFilter.full, 'Full'),
    ];

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppStaggeredFade(
                index: 0,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Daily\nBatchIt Deals',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w800,
                          height: 1.04,
                        ),
                      ),
                    ),
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: scheme.outlineVariant),
                      ),
                      child: Icon(Icons.search_rounded, color: scheme.onSurface),
                    ),
                  ],
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
              const SizedBox(height: 22),
              Row(
                children: [
                  Text(
                    'Popular Batches',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'See all',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: batchProvider.isLoading
                    ? Center(
                        child: CircularProgressIndicator(color: scheme.primary),
                      )
                    : filteredBatches.isEmpty
                        ? Center(
                            child: Text(
                              'No batches found for this filter.',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          )
                        : GridView.builder(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
