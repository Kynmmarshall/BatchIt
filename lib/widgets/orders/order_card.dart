import 'package:batchit/core/utils/formatters.dart';
import 'package:batchit/models/order.dart';
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(order.productName, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('${formatKg(order.quantityKg)} • ${order.hubName}'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                statusLabel,
                style: theme.textTheme.labelMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
