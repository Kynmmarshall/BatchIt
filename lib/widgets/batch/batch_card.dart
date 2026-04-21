import 'package:batchit/core/utils/formatters.dart';
import 'package:batchit/models/batch.dart';
import 'package:batchit/themes/app_colors.dart';
import 'package:batchit/themes/app_icons.dart';
import 'package:batchit/themes/app_motion.dart';
import 'package:batchit/themes/app_radius.dart';
import 'package:batchit/themes/app_shadows.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:flutter/material.dart';

class BatchCard extends StatelessWidget {
  const BatchCard({
    super.key,
    required this.batch,
    required this.joinLabel,
    required this.onTap,
  });

  final Batch batch;
  final String joinLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [Color(0xFF1A2823), Color(0xFF15211D)]
                : const [Color(0xFFFFFFFF), Color(0xFFF3FBF7)],
          ),
          boxShadow: AppShadows.card(theme.brightness),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        batch.productName,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: batch.isFull
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        batch.isFull ? 'FULL' : 'OPEN',
                        style: theme.textTheme.labelSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${formatKg(batch.currentQuantityKg)} / ${formatKg(batch.bulkSizeKg)}',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                TweenAnimationBuilder<double>(
                  duration: AppMotion.slow,
                  curve: AppMotion.emphasized,
                  tween: Tween<double>(begin: 0, end: batch.progress),
                  builder: (context, value, _) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: LinearProgressIndicator(
                        value: value,
                        minHeight: 10,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? AppColors.accent : theme.colorScheme.primary,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Icon(
                      Icons.place_outlined,
                      size: AppIcons.sm,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(batch.locationName, style: theme.textTheme.bodySmall),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(
                      Icons.storefront_outlined,
                      size: AppIcons.sm,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(batch.hubName, style: theme.textTheme.bodySmall),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.tonalIcon(
                    onPressed: onTap,
                    icon: const Icon(Icons.arrow_forward_rounded, size: AppIcons.md),
                    label: Text(joinLabel),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
