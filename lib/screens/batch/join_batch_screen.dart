import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/providers/batch_provider.dart';
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
  double _selectedQuantityKg = 5;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final batch = context.watch<BatchProvider>().findById(widget.batchId);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (batch == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.joinBatch)),
        body: AppScreenContainer(
          child: Center(child: Text(l10n.batchNotFound)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.joinBatch)),
      body: AppScreenContainer(
        child: ListView(
          children: [
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
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.joinQuantityHint,
                        ),
                        onChanged: (value) {
                          final parsed = double.tryParse(value.trim());
                          if (parsed != null && parsed > 0) {
                            setState(() {
                              _selectedQuantityKg = parsed;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _QuantityChip(
                            label: '5 kg',
                            selected: _selectedQuantityKg == 5,
                            onTap: () => _setQuantity(5),
                          ),
                          _QuantityChip(
                            label: '10 kg',
                            selected: _selectedQuantityKg == 10,
                            onTap: () => _setQuantity(10),
                          ),
                          _QuantityChip(
                            label: '15 kg',
                            selected: _selectedQuantityKg == 15,
                            onTap: () => _setQuantity(15),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppPrimaryButton(
                        label: l10n.joinConfirm,
                        icon: Icons.check_circle_outline,
                        onPressed: () {
                          final value = double.tryParse(_quantityController.text.trim());
                          final quantity = value ?? _selectedQuantityKg;
                          if (quantity <= 0) {
                            return;
                          }

                          context.read<BatchProvider>().joinBatch(
                                batchId: widget.batchId,
                                quantityKg: quantity,
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.joinSuccess)),
                          );
                          Navigator.pop(context);
                        },
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
      side: BorderSide(color: selected ? scheme.primary : scheme.outlineVariant),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
    );
  }
}
