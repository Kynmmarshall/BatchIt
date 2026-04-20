import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/models/order.dart';
import 'package:batchit/providers/order_provider.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:batchit/widgets/common/app_screen_container.dart';
import 'package:batchit/widgets/orders/order_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrders();
    });
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myOrders)),
      body: AppScreenContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.myOrders,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: orderProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      itemCount: orderProvider.orders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final order = orderProvider.orders[index];
                        return OrderCard(
                          order: order,
                          statusLabel: _statusLabel(context, order.status),
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
