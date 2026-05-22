import 'package:batchit/core/app_routes.dart';
import 'package:batchit/core/formatters.dart';
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/models/batch.dart';
import 'package:batchit/models/order.dart';
import 'package:batchit/providers/batch_provider.dart';
import 'package:batchit/providers/order_provider.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:batchit/widgets/app_screen_container.dart';
import 'package:batchit/widgets/app_staggered_fade.dart';
import 'package:batchit/widgets/order_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyBatchesScreen extends StatefulWidget {
  const MyBatchesScreen({super.key});

  @override
  State<MyBatchesScreen> createState() => _MyBatchesScreenState();
}

class _MyBatchesScreenState extends State<MyBatchesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<BatchProvider>().loadMyCreatedBatches();
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
    final batchProvider = context.watch<BatchProvider>();
    final orderProvider = context.watch<OrderProvider>();

    final createdBatches = batchProvider.myCreatedBatches;
    final joinedOrders = orderProvider.orders;
    final isLoading = batchProvider.isLoading || orderProvider.isLoading;
    final isEmpty = createdBatches.isEmpty && joinedOrders.isEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('My Batches')),
      body: AppScreenContainer(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : isEmpty
                ? _EmptyState(l10n: l10n)
                : _BatchList(
                    createdBatches: createdBatches,
                    joinedOrders: joinedOrders,
                    statusLabel: _statusLabel,
                  ),
      ),
      bottomNavigationBar: Material(
        color: Theme.of(context).colorScheme.surface,
        elevation: 4,
        shadowColor: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.xs, AppSpacing.md, AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.createBatch),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Create Batch'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context, AppRoutes.shell, (r) => false),
                    icon: const Icon(Icons.search_rounded),
                    label: const Text('Join a Batch'),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No batches yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Create a batch or join one from the home screen.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _BatchList extends StatelessWidget {
  const _BatchList({
    required this.createdBatches,
    required this.joinedOrders,
    required this.statusLabel,
  });

  final List<Batch> createdBatches;
  final List<Order> joinedOrders;
  final String Function(BuildContext, OrderStatus) statusLabel;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        if (createdBatches.isNotEmpty) ...[
          AppStaggeredFade(
            index: 0,
            child: _SectionHeader(label: 'Batches I Created'),
          ),
          ...createdBatches.asMap().entries.map((e) => AppStaggeredFade(
                index: e.key + 1,
                child: _CreatedBatchItem(batch: e.value),
              )),
          const SizedBox(height: AppSpacing.md),
        ],
        if (joinedOrders.isNotEmpty) ...[
          AppStaggeredFade(
            index: createdBatches.length,
            child: _SectionHeader(label: 'Batches I Joined'),
          ),
          ...joinedOrders.asMap().entries.map((e) => AppStaggeredFade(
                index: createdBatches.length + e.key + 1,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: OrderCard(
                    order: e.value,
                    statusLabel: statusLabel(context, e.value.status),
                  ),
                ),
              )),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _CreatedBatchItem extends StatelessWidget {
  const _CreatedBatchItem({required this.batch});
  final Batch batch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Card(
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
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Created',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${batch.locationName}${batch.hubName.isNotEmpty ? " • ${batch.hubName}" : ""}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              LinearProgressIndicator(
                value: batch.progress,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${formatKg(batch.currentQuantityKg)} / ${formatKg(batch.bulkSizeKg)} filled',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
