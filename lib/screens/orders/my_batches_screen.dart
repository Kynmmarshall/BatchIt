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

  Future<void> _showEditQuantityDialog(
      BuildContext context, Order order) async {
    final l10n = AppLocalizations.of(context)!;
    // Capture before any async gap
    final orderProvider = context.read<OrderProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final controller =
        TextEditingController(text: order.quantityKg.toString());
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.myBatchesEditQuantity),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: l10n.myBatchesNewQuantityHint,
              suffixText: 'kg',
            ),
            validator: (v) {
              final val = double.tryParse(v ?? '');
              if (val == null || val <= 0) return l10n.joinQuantityHint;
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.providerBack),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
            },
            child: Text(l10n.myBatchesUpdateQuantity),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final newQty = double.tryParse(controller.text);
    if (newQty == null) return;

    try {
      await orderProvider.updateQuantity(order.id, newQty);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.myBatchesQuantityUpdated)),
      );
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.myBatchesQuantityError)),
      );
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
      appBar: AppBar(title: Text(l10n.myOrders)),
      body: AppScreenContainer(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : isEmpty
                ? _EmptyState(l10n: l10n)
                : _BatchList(
                    createdBatches: createdBatches,
                    joinedOrders: joinedOrders,
                    statusLabel: _statusLabel,
                    onEditQuantity: (order) =>
                        _showEditQuantityDialog(context, order),
                    l10n: l10n,
                  ),
      ),
      bottomNavigationBar: Material(
        color: Theme.of(context).colorScheme.surface,
        elevation: 4,
        shadowColor: Theme.of(context)
            .colorScheme
            .shadow
            .withValues(alpha: 0.08),
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
                    label: Text(l10n.createBatch),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context, AppRoutes.shell, (r) => false),
                    icon: const Icon(Icons.search_rounded),
                    label: Text(l10n.myBatchesJoinBtn),
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

// ---------------------------------------------------------------------------

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
          Text(l10n.myBatchesEmpty,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.myBatchesEmptySubtitle,
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

// ---------------------------------------------------------------------------

class _BatchList extends StatelessWidget {
  const _BatchList({
    required this.createdBatches,
    required this.joinedOrders,
    required this.statusLabel,
    required this.onEditQuantity,
    required this.l10n,
  });

  final List<Batch> createdBatches;
  final List<Order> joinedOrders;
  final String Function(BuildContext, OrderStatus) statusLabel;
  final void Function(Order) onEditQuantity;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        if (createdBatches.isNotEmpty) ...[
          AppStaggeredFade(
            index: 0,
            child: _SectionHeader(label: l10n.myBatchesSectionCreated),
          ),
          ...createdBatches.asMap().entries.map((e) => AppStaggeredFade(
                index: e.key + 1,
                child: _CreatedBatchItem(batch: e.value, l10n: l10n),
              )),
          const SizedBox(height: AppSpacing.md),
        ],
        if (joinedOrders.isNotEmpty) ...[
          AppStaggeredFade(
            index: createdBatches.length,
            child: _SectionHeader(label: l10n.myBatchesSectionJoined),
          ),
          ...joinedOrders.asMap().entries.map((e) => AppStaggeredFade(
                index: createdBatches.length + e.key + 1,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Stack(
                    children: [
                      OrderCard(
                        order: e.value,
                        statusLabel: statusLabel(context, e.value.status),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: _EditQtyButton(
                          onTap: () => onEditQuantity(e.value),
                          l10n: l10n,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _EditQtyButton extends StatelessWidget {
  const _EditQtyButton({required this.onTap, required this.l10n});
  final VoidCallback onTap;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: l10n.myBatchesEditQuantity,
      child: Material(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(8),
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(Icons.edit_outlined, size: 18, color: scheme.primary),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _CreatedBatchItem extends StatelessWidget {
  const _CreatedBatchItem({required this.batch, required this.l10n});
  final Batch batch;
  final AppLocalizations l10n;

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // thumbnail — VPS image or asset fallback
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: batch.imageUrl != null &&
                              batch.imageUrl!.isNotEmpty
                          ? Image.network(
                              batch.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _placeholder(scheme),
                            )
                          : Image.asset(
                              batch.imageAssetPath,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _placeholder(scheme),
                            ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(batch.productName,
                                  style: theme.textTheme.titleMedium),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: scheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                l10n.myBatchesCreatedBadge,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: scheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${batch.locationName}'
                          '${batch.hubName.isNotEmpty ? " • ${batch.hubName}" : ""}',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              LinearProgressIndicator(
                value: batch.progress,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.myBatchesFilled(
                  formatKg(batch.currentQuantityKg),
                  formatKg(batch.bulkSizeKg),
                ),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder(ColorScheme scheme) => Container(
        color: scheme.surfaceContainerHighest,
        child: Icon(Icons.inventory_2_outlined,
            color: scheme.onSurfaceVariant),
      );
}
