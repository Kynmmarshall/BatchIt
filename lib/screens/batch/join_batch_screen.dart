import 'package:batchit/core/app_routes.dart';
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/models/batch.dart';
import 'package:batchit/providers/batch_provider.dart';
import 'package:batchit/services/api_client.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:batchit/widgets/app_primary_button.dart';
import 'package:batchit/widgets/app_screen_container.dart';
import 'package:batchit/widgets/app_staggered_fade.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class JoinBatchScreen extends StatefulWidget {
  const JoinBatchScreen({super.key, required this.batchId});

  final String batchId;

  @override
  State<JoinBatchScreen> createState() => _JoinBatchScreenState();
}

class _JoinBatchScreenState extends State<JoinBatchScreen> {
  final TextEditingController _quantityController = TextEditingController();
  double _selectedQuantityKg = 1;
  bool _isRefreshing = true;
  bool _isSubmitting = false;

  /// Quick-pick quantities per unit type.
  static List<double> _presetsFor(String unit) {
    switch (unit) {
      case 'g':
        return [100, 250, 500];
      case 'L':
        return [1, 5, 10];
      case 'mL':
        return [250, 500, 1000];
      case 'units':
        return [1, 2, 5];
      case 'boxes':
        return [1, 2, 3];
      case 'kg':
      default:
        return [5, 10, 15];
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshBatch());
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _refreshBatch() async {
    if (!mounted) return;
    setState(() => _isRefreshing = true);
    try {
      await context.read<BatchProvider>().refreshBatch(widget.batchId);
    } catch (e) {
      debugPrint('[JoinBatchScreen] batch refresh failed: $e');
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  Future<void> _confirmJoin(Batch batch) async {
    final value = double.tryParse(_quantityController.text.trim());
    final quantity = value ?? _selectedQuantityKg;
    if (quantity <= 0) return;

    final batchProvider = context.read<BatchProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    final l10n = AppLocalizations.of(context)!;
    final batchId = widget.batchId;
    final batchName = batch.productName;

    setState(() => _isSubmitting = true);
    try {
      await batchProvider.joinBatch(batchId: batchId, quantityKg: quantity);
      if (!mounted) return;

      nav.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.joinSuccess),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Open Chat',
            onPressed: () => nav.pushNamed(
              AppRoutes.batchChat,
              arguments: {'batchId': batchId, 'batchName': batchName},
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(_joinErrorMessage(e, l10n))),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _joinErrorMessage(Object error, AppLocalizations l10n) {
    if (error is ApiException && error.message.isNotEmpty) {
      return error.message;
    }
    return l10n.errorMessage;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final batch = context.watch<BatchProvider>().findById(widget.batchId);
    final canJoin = batch != null && batch.canJoin;
    final canSubmit = canJoin && !_isRefreshing && !_isSubmitting;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (batch == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.joinBatch)),
        body: AppScreenContainer(
          child: Center(
            child: _isRefreshing
                ? const CircularProgressIndicator()
                : Text(l10n.batchNotFound),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.joinBatch)),
      body: AppScreenContainer(
        child: ListView(
          children: [
            if (_isRefreshing) const LinearProgressIndicator(),
            if (_isRefreshing) const SizedBox(height: AppSpacing.md),
            if (!canJoin)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    batch.isFull
                        ? 'This batch is already full.'
                        : 'This batch is no longer open for joining.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
            if (!canJoin) const SizedBox(height: AppSpacing.md),
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
                      scheme.primary.withValues(alpha: 0.18),
                      scheme.secondaryContainer.withValues(alpha: 0.94),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.joinBatchTitle,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.joinBatchSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppStaggeredFade(
              index: 1,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.batchSnapshot,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        batch.productName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${batch.locationName} • ${batch.hubName}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      LinearProgressIndicator(
                        value: batch.progress,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${batch.currentQuantityKg.toStringAsFixed(0)} / ${batch.bulkSizeKg.toStringAsFixed(0)} kg',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '${(batch.progress * 100).round()}%',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppStaggeredFade(
              index: 2,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.claimedQuantity,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      TextFormField(
                        controller: _quantityController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: l10n.joinQuantityHint,
                          suffixText: batch.unit,
                        ),
                        onChanged: (value) {
                          final parsed = double.tryParse(value.trim());
                          if (parsed != null && parsed > 0) {
                            setState(() => _selectedQuantityKg = parsed);
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _presetsFor(batch.unit)
                            .map(
                              (qty) => _QuantityChip(
                                label: '$qty ${batch.unit}',
                                selected: _selectedQuantityKg == qty,
                                onTap: () => _setQuantity(qty),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppPrimaryButton(
                        label: l10n.joinConfirm,
                        icon: Icons.check_circle_outline,
                        isLoading: _isSubmitting,
                        onPressed: canSubmit ? () => _confirmJoin(batch) : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setQuantity(double value) {
    setState(() {
      _selectedQuantityKg = value;
      _quantityController.text = value.toStringAsFixed(0);
    });
  }
}

class _QuantityChip extends StatelessWidget {
  const _QuantityChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: scheme.primary,
      backgroundColor: scheme.surfaceContainerHighest,
      labelStyle: TextStyle(
        color: selected ? scheme.onPrimary : scheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(
        color: selected ? scheme.primary : scheme.outlineVariant,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    );
  }
}
