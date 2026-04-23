import 'package:batchit/core/formatters.dart';
import 'package:batchit/models/order.dart';
import 'package:batchit/themes/app_icons.dart';
import 'package:batchit/themes/app_radius.dart';
import 'package:batchit/themes/app_shadows.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:flutter/material.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    required this.statusLabel,
  });

  final Order order;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.card(theme.brightness),
          gradient: LinearGradient(
            colors: theme.brightness == Brightness.dark
                ? const [Color(0xFF1A2823), Color(0xFF13211C)]
                : const [Color(0xFFFFFFFF), Color(0xFFF6FBF8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(order.productName, style: theme.textTheme.titleMedium),
                ),
                Icon(
                  Icons.local_shipping_outlined,
                  size: AppIcons.md,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${formatKg(order.quantityKg)} • ${order.hubName}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline, size: AppIcons.sm - 2),
                  const SizedBox(width: 6),
                  Text(
                    statusLabel,
                    style: theme.textTheme.labelMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
