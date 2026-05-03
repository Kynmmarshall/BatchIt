import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/models/order.dart';
import 'package:batchit/providers/order_provider.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:batchit/widgets/app_screen_container.dart';
import 'package:batchit/widgets/app_staggered_fade.dart';
import 'package:batchit/widgets/order_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:batchit/screens/orders/create_order_screen.dart';

class MyBatchesScreen extends StatefulWidget {
  const MyBatchesScreen({super.key});

  @override
  State<MyBatchesScreen> createState() => _MyBatchesScreenState();
}

class _MyBatchesScreenState extends State<MyBatchesScreen> {
  OrderStatus? _filter;
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
    final orders = orderProvider.orders.where((o) => _filter == null ? true : o.status == _filter).toList();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myOrders)),
      body: AppScreenContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppStaggeredFade(
              index: 0,
              child: Text(
                l10n.myOrders,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Text(l10n.orderStatusPending),
                  selected: _filter == OrderStatus.pending,
                  onSelected: (s) => setState(() => _filter = s ? OrderStatus.pending : null),
                ),
                ChoiceChip(
                  label: Text(l10n.orderStatusTriggered),
                  selected: _filter == OrderStatus.triggered,
                  onSelected: (s) => setState(() => _filter = s ? OrderStatus.triggered : null),
                ),
                ChoiceChip(
                  label: Text(l10n.orderStatusDelivered),
                  selected: _filter == OrderStatus.delivered,
                  onSelected: (s) => setState(() => _filter = s ? OrderStatus.delivered : null),
                ),
                ChoiceChip(
                  label: Text(l10n.orderStatusCompleted),
                  selected: _filter == OrderStatus.completed,
                  onSelected: (s) => setState(() => _filter = s ? OrderStatus.completed : null),
                ),
                ChoiceChip(
                  label: Text(l10n.seeAll),
                  selected: _filter == null,
                  onSelected: (s) => setState(() => _filter = s ? null : _filter),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: orderProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : orders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.receipt_long_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                              const SizedBox(height: AppSpacing.sm),
                              Text(l10n.myOrders, style: Theme.of(context).textTheme.titleLarge),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                l10n.orderEmptySubtitle,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              ElevatedButton(
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateOrderScreen())),
                                child: Text(l10n.createOrder),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: orders.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            final order = orders[index];
                            return AppStaggeredFade(
                              index: index + 1,
                              child: OrderCard(
                                order: order,
                                statusLabel: _statusLabel(context, order.status),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateOrderScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}
