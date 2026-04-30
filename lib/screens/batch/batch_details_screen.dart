import 'package:batchit/core/app_routes.dart';
import 'package:batchit/core/formatters.dart';
import 'package:batchit/themes/app_icons.dart';
import 'package:batchit/themes/app_motion.dart';
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/providers/batch_provider.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:batchit/widgets/app_primary_button.dart';
import 'package:batchit/widgets/app_screen_container.dart';
import 'package:batchit/widgets/app_staggered_fade.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BatchDetailsScreen extends StatelessWidget {
  const BatchDetailsScreen({super.key, required this.batchId});

  final String batchId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final batch = context.watch<BatchProvider>().findById(batchId);

    if (batch == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.batchDetails)),
        body: Center(child: Text(l10n.batchNotFound)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.batchDetails)),
      body: AppScreenContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
                      Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.94),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        batch.imageAssetPath,
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 96,
                          height: 96,
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.inventory_2_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            batch.productName,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '${batch.locationName} • ${batch.hubName}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: _DetailStatChip(
                                  label: l10n.progress,
                                  value: '${(batch.progress * 100).round()}%',
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: _DetailStatChip(
                                  label: l10n.quantity,
                                  value: '${formatKg(batch.currentQuantityKg)} / ${formatKg(batch.bulkSizeKg)}',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppStaggeredFade(
              index: 1,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TweenAnimationBuilder<double>(
                        duration: AppMotion.slow,
                        curve: AppMotion.emphasized,
                        tween: Tween<double>(begin: 0, end: batch.progress),
                        builder: (context, value, _) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(value: value, minHeight: 10),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          const Icon(Icons.place_outlined, size: AppIcons.md),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              '${l10n.location}: ${batch.locationName}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          const Icon(Icons.storefront_outlined, size: AppIcons.md),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              '${l10n.hub}: ${batch.hubName}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            AppStaggeredFade(
              index: 2,
              child: AppPrimaryButton(
                label: l10n.joinBatch,
                icon: Icons.group_add_rounded,
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.joinBatch,
                    arguments: batchId,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailStatChip extends StatelessWidget {
  const _DetailStatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
          ),
        ],
      ),
    );
  }
}
