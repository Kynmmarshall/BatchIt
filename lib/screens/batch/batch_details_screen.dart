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
        body: const Center(child: Text('Batch not found')),
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
              child: Text(
                batch.productName,
                style: Theme.of(context).textTheme.headlineSmall,
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
                      Text(
                        '${formatKg(batch.currentQuantityKg)} / ${formatKg(batch.bulkSizeKg)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
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
                          Expanded(child: Text('${l10n.location}: ${batch.locationName}')),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          const Icon(Icons.storefront_outlined, size: AppIcons.md),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(child: Text('${l10n.hub}: ${batch.hubName}')),
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
