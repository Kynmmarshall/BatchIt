import 'package:batchit/core/app_routes.dart';
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/providers/batch_provider.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:batchit/widgets/app_primary_button.dart';
import 'package:batchit/widgets/app_screen_container.dart';
import 'package:batchit/widgets/app_staggered_fade.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateBatchScreen extends StatefulWidget {
  const CreateBatchScreen({super.key});

  @override
  State<CreateBatchScreen> createState() => _CreateBatchScreenState();
}

class _CreateBatchScreenState extends State<CreateBatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productController = TextEditingController();
  final _locationController = TextEditingController();
  final _noteController = TextEditingController();
  final _bulkController = TextEditingController(text: '50');

  static const _productOptions = <_PresetOption>[
    _PresetOption(value: 'Potatoes', labelKey: 'productPotatoes'),
    _PresetOption(value: 'Tomatoes', labelKey: 'productTomatoes'),
    _PresetOption(value: 'Onions', labelKey: 'productOnions'),
  ];

  static const _providerOptions = <_PresetOption>[
    _PresetOption(value: 'Hub Auto', labelKey: 'providerAuto'),
    _PresetOption(value: 'Hub Ain Sebaa', labelKey: 'providerAinSebaa'),
    _PresetOption(value: 'Hub Centre', labelKey: 'providerCentre'),
    _PresetOption(value: 'Hub East', labelKey: 'providerEast'),
  ];

  static const _bulkOptions = <_PresetOption>[
    _PresetOption(value: '50', labelKey: 'bulkKg50'),
    _PresetOption(value: '30', labelKey: 'bulkKg30'),
    _PresetOption(value: '40', labelKey: 'bulkKg40'),
  ];

  String _selectedProduct = 'Potatoes';
  String _selectedProvider = 'Hub Auto';

  @override
  void dispose() {
    _productController.dispose();
    _locationController.dispose();
    _noteController.dispose();
    _bulkController.dispose();
    super.dispose();
  }

  Future<void> _createBatch() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final bulk = double.tryParse(_bulkController.text.trim());
    if (bulk == null || bulk <= 0) {
      return;
    }

    final provider = context.read<BatchProvider>();
    final batch = await provider.createBatch(
      productName: _productController.text.trim(),
      bulkSizeKg: bulk,
      location: _locationController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.batchCreated)),
    );

    Navigator.pushNamed(
      context,
      AppRoutes.batchDetails,
      arguments: batch.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.createBatch)),
      body: AppScreenContainer(
        child: Form(
          key: _formKey,
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
                        l10n.createBatchTitle,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.createBatchSubtitle,
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
                          l10n.productSelection,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _productOptions
                              .map(
                                (option) => _PresetChip(
                                  label: _localizedPresetLabel(l10n, option.labelKey),
                                  selected: _selectedProduct == option.value,
                                  onTap: () {
                                    setState(() {
                                      _selectedProduct = option.value;
                                      _productController.text = option.value;
                                    });
                                  },
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          controller: _productController,
                          decoration: InputDecoration(
                            labelText: l10n.customProduct,
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty ? l10n.productName : null,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          l10n.bulkSelection,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _bulkOptions
                              .map(
                                (option) => _PresetChip(
                                  label: _localizedPresetLabel(l10n, option.labelKey),
                                  selected: _bulkController.text.trim() == option.value,
                                  onTap: () {
                                    setState(() {
                                      _bulkController.text = option.value;
                                    });
                                  },
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          controller: _bulkController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: l10n.bulkSize),
                          validator: (value) =>
                              value == null || value.trim().isEmpty ? l10n.bulkSize : null,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          l10n.providerSelection,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _providerOptions
                              .map(
                                (option) => _PresetChip(
                                  label: _localizedPresetLabel(l10n, option.labelKey),
                                  selected: _selectedProvider == option.value,
                                  onTap: () {
                                    setState(() {
                                      _selectedProvider = option.value;
                                      _locationController.text = option.value;
                                    });
                                  },
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          controller: _locationController,
                          decoration: InputDecoration(labelText: l10n.location),
                          validator: (value) =>
                              value == null || value.trim().isEmpty ? l10n.location : null,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        TextFormField(
                          controller: _noteController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: l10n.batchNoteOptional,
                            hintText: l10n.batchNoteHint,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppPrimaryButton(
                          label: l10n.submit,
                          icon: Icons.add_task_rounded,
                          onPressed: _createBatch,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _localizedPresetLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'productPotatoes':
        return l10n.productPotatoes;
      case 'productTomatoes':
        return l10n.productTomatoes;
      case 'productOnions':
        return l10n.productOnions;
      case 'providerAuto':
        return l10n.providerAuto;
      case 'providerAinSebaa':
        return l10n.providerAinSebaa;
      case 'providerCentre':
        return l10n.providerCentre;
      case 'providerEast':
        return l10n.providerEast;
      case 'bulkKg50':
        return l10n.bulkKg50;
      case 'bulkKg30':
        return l10n.bulkKg30;
      case 'bulkKg40':
        return l10n.bulkKg40;
      default:
        return key;
    }
  }
}

class _PresetOption {
  const _PresetOption({required this.value, required this.labelKey});

  final String value;
  final String labelKey;
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({required this.label, required this.selected, required this.onTap});

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
