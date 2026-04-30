import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/models/order.dart';
import 'package:batchit/providers/order_provider.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:batchit/widgets/app_screen_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final order = context.watch<OrderProvider>().findById(orderId);

    if (order == null) {
      return Scaffold(appBar: AppBar(title: Text(l10n.orderDetails)), body: Center(child: Text(l10n.routeNotFound)));
    }

    final imagePath = _resolveAsset(order.productName);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.orderDetails)),
      body: AppScreenContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(imagePath, width: 96, height: 96, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 96, height: 96, color: Theme.of(context).colorScheme.surfaceContainerHighest)),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.productName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: AppSpacing.xs),
                      Text('${order.quantityKg.toStringAsFixed(0)} kg • ${order.hubName}', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l10n.orderStatusPending, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(_statusLabel(context, order.status), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                ]),
              ),
            ),
            const Spacer(),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.read<OrderProvider>().updateOrderStatus(order.id, OrderStatus.completed);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.orderStatusCompleted)));
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.read<OrderProvider>().updateOrderStatus(order.id, OrderStatus.triggered);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.orderStatusTriggered)));
                    Navigator.pop(context);
                  },
                  child: Text(l10n.submit),
                ),
              ),
            ])
          ],
        ),
      ),
    );
  }

  String _statusLabel(BuildContext context, OrderStatus status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case OrderStatus.pending:
        return l10n.orderStatusPending;
      case OrderStatus.triggered:
        return l10n.orderStatusTriggered;
      case OrderStatus.delivered:
        return l10n.orderStatusDelivered;
      case OrderStatus.completed:
        return l10n.orderStatusCompleted;
    }
  }

  String _resolveAsset(String productName) {
    final name = productName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'^_+|_+$'), '');
    return 'assets/batches/$name.jpg';
  }
}
