import 'dart:io';
import 'package:batchit/core/app_routes.dart';
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/models/provider_profile.dart';
import 'package:batchit/providers/batch_provider.dart';
import 'package:batchit/providers/provider_provider.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:batchit/widgets/app_primary_button.dart';
import 'package:batchit/widgets/app_screen_container.dart';
import 'package:batchit/widgets/app_staggered_fade.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

// Sealed result for provider picker bottom sheet
abstract class _PickerResult {}

class _AutoPicked extends _PickerResult {}

class _ProviderPicked extends _PickerResult {
  _ProviderPicked(this.provider);
  final ProviderProfile provider;
}

// ─────────────────────────────────────────────────────────────────────────────
// CreateBatchScreen
// ─────────────────────────────────────────────────────────────────────────────

class CreateBatchScreen extends StatefulWidget {
  const CreateBatchScreen({super.key, this.preselectedProviderId});

  final String? preselectedProviderId;

  @override
  State<CreateBatchScreen> createState() => _CreateBatchScreenState();
}

class _CreateBatchScreenState extends State<CreateBatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productController = TextEditingController();
  final _noteController = TextEditingController();
  final _bulkController = TextEditingController(text: '50');

  static const _productOptions = <_PresetOption>[
    _PresetOption(value: 'Potatoes', labelKey: 'productPotatoes'),
    _PresetOption(value: 'Tomatoes', labelKey: 'productTomatoes'),
    _PresetOption(value: 'Onions', labelKey: 'productOnions'),
  ];

  static const _bulkOptions = <_PresetOption>[
    _PresetOption(value: '50', labelKey: 'bulkKg50'),
    _PresetOption(value: '30', labelKey: 'bulkKg30'),
    _PresetOption(value: '40', labelKey: 'bulkKg40'),
  ];

  String _selectedProduct = 'Potatoes';
  ProviderProfile? _selectedProvider;
  File? _batchImage;

  @override
  void initState() {
    super.initState();
    _productController.text = 'Potatoes';
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProviders());
  }

  Future<void> _loadProviders() async {
    if (!mounted) return;
    final pp = context.read<ProviderProvider>();
    if (pp.verifiedProviders.isEmpty) {
      await pp.loadVerifiedProviders();
    }
    if (!mounted || widget.preselectedProviderId == null) return;
    final found = pp.findById(widget.preselectedProviderId!);
    if (found != null) setState(() => _selectedProvider = found);
  }

  @override
  void dispose() {
    _productController.dispose();
    _noteController.dispose();
    _bulkController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked != null && mounted) {
      setState(() => _batchImage = File(picked.path));
    }
  }

  Future<void> _openProviderPicker() async {
    final providers = context.read<ProviderProvider>().verifiedProviders;
    final result = await showModalBottomSheet<_PickerResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _ProviderPickerSheet(
        currentProvider: _selectedProvider,
        providers: providers,
      ),
    );
    if (!mounted || result == null) return;
    if (result is _AutoPicked) {
      setState(() => _selectedProvider = null);
    } else if (result is _ProviderPicked) {
      setState(() => _selectedProvider = result.provider);
    }
  }

  Future<void> _createBatch() async {
    if (!_formKey.currentState!.validate()) return;
    final bulk = double.tryParse(_bulkController.text.trim());
    if (bulk == null || bulk <= 0) return;

    try {
      final batch = await context.read<BatchProvider>().createBatch(
        productName: _productController.text.trim(),
        bulkSizeKg: bulk,
        location: _selectedProvider?.businessName ?? 'Auto',
        providerId: _selectedProvider?.id,
        notes: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        image: _batchImage,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.batchCreated)),
      );
      Navigator.pushNamed(context, AppRoutes.batchDetails, arguments: batch.id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.errorMessage)),
      );
    }
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
              // Header banner
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

              // Form card
              AppStaggeredFade(
                index: 1,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Product selection ──────────────────────────────
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
                                (opt) => _PresetChip(
                                  label: _localizedLabel(l10n, opt.labelKey),
                                  selected: _selectedProduct == opt.value,
                                  onTap: () => setState(() {
                                    _selectedProduct = opt.value;
                                    _productController.text = opt.value;
                                  }),
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
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? l10n.productName : null,
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // ── Bulk size ──────────────────────────────────────
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
                                (opt) => _PresetChip(
                                  label: _localizedLabel(l10n, opt.labelKey),
                                  selected:
                                      _bulkController.text.trim() == opt.value,
                                  onTap: () => setState(
                                    () => _bulkController.text = opt.value,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          controller: _bulkController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: l10n.bulkSize),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? l10n.bulkSize : null,
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // ── Provider selection ─────────────────────────────
                        Text(
                          l10n.providerSelection,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        _ProviderSelector(
                          l10n: l10n,
                          selected: _selectedProvider,
                          scheme: scheme,
                          theme: theme,
                          onTap: _openProviderPicker,
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // ── Product image ──────────────────────────────────
                        Text(
                          l10n.batchImageLabel,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            height: 140,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: scheme.outlineVariant,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: _batchImage != null
                                ? Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          _batchImage!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: AppSpacing.xs,
                                        right: AppSpacing.xs,
                                        child: FilledButton.icon(
                                          onPressed: _pickImage,
                                          style: FilledButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: AppSpacing.sm,
                                                vertical: 4),
                                            tapTargetSize:
                                                MaterialTapTargetSize.shrinkWrap,
                                            textStyle:
                                                theme.textTheme.labelSmall,
                                          ),
                                          icon: const Icon(Icons.edit_rounded,
                                              size: 14),
                                          label: Text(l10n.batchImageChange),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_photo_alternate_rounded,
                                          size: 36,
                                          color: scheme.onSurfaceVariant),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        l10n.batchImageHint,
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // ── Optional note ──────────────────────────────────
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

  String _localizedLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'productPotatoes':
        return l10n.productPotatoes;
      case 'productTomatoes':
        return l10n.productTomatoes;
      case 'productOnions':
        return l10n.productOnions;
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

// ─────────────────────────────────────────────────────────────────────────────
// _ProviderSelector — inline selector showing current state with tap-to-change
// ─────────────────────────────────────────────────────────────────────────────

class _ProviderSelector extends StatelessWidget {
  const _ProviderSelector({
    required this.l10n,
    required this.selected,
    required this.scheme,
    required this.theme,
    required this.onTap,
  });

  final AppLocalizations l10n;
  final ProviderProfile? selected;
  final ColorScheme scheme;
  final ThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: scheme.outlineVariant),
          borderRadius: BorderRadius.circular(16),
          color: scheme.surfaceContainerLowest,
        ),
        child: selected == null
            ? _AutoRow(l10n: l10n, scheme: scheme, theme: theme)
            : _SelectedRow(
                l10n: l10n,
                provider: selected!,
                scheme: scheme,
                theme: theme,
              ),
      ),
    );
  }
}

class _AutoRow extends StatelessWidget {
  const _AutoRow({
    required this.l10n,
    required this.scheme,
    required this.theme,
  });

  final AppLocalizations l10n;
  final ColorScheme scheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: scheme.primaryContainer,
          child: Icon(
            Icons.hub_rounded,
            color: scheme.onPrimaryContainer,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.providerAuto,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                l10n.batchAutoProviderDesc,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Text(
          l10n.batchSelectProvider,
          style: theme.textTheme.labelMedium?.copyWith(color: scheme.primary),
        ),
      ],
    );
  }
}

class _SelectedRow extends StatelessWidget {
  const _SelectedRow({
    required this.l10n,
    required this.provider,
    required this.scheme,
    required this.theme,
  });

  final AppLocalizations l10n;
  final ProviderProfile provider;
  final ColorScheme scheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: scheme.primaryContainer,
          backgroundImage:
              provider.logoUrl != null ? NetworkImage(provider.logoUrl!) : null,
          child: provider.logoUrl == null
              ? Text(
                  provider.businessName[0].toUpperCase(),
                  style: TextStyle(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      provider.businessName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.verified_rounded, size: 14, color: scheme.primary),
                ],
              ),
              Text(
                provider.address,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Text(
          l10n.batchChangeProvider,
          style: theme.textTheme.labelMedium?.copyWith(color: scheme.primary),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ProviderPickerSheet — draggable bottom sheet for picking a provider
// ─────────────────────────────────────────────────────────────────────────────

class _ProviderPickerSheet extends StatefulWidget {
  const _ProviderPickerSheet({
    required this.currentProvider,
    required this.providers,
  });

  final ProviderProfile? currentProvider;
  final List<ProviderProfile> providers;

  @override
  State<_ProviderPickerSheet> createState() => _ProviderPickerSheetState();
}

class _ProviderPickerSheetState extends State<_ProviderPickerSheet> {
  String _query = '';

  List<ProviderProfile> get _filtered => widget.providers
      .where(
        (p) =>
            _query.isEmpty ||
            p.businessName.toLowerCase().contains(_query.toLowerCase()) ||
            p.address.toLowerCase().contains(_query.toLowerCase()),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          // Drag handle
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.outlineVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.providerSelection,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          const SizedBox(height: 4),
          // List
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              children: [
                // Auto option
                _PickerTile(
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: scheme.primaryContainer,
                    child: Icon(
                      Icons.hub_rounded,
                      color: scheme.onPrimaryContainer,
                      size: 18,
                    ),
                  ),
                  title: l10n.providerAuto,
                  subtitle: l10n.batchAutoProviderDesc,
                  isSelected: widget.currentProvider == null,
                  onSelect: () => Navigator.pop(context, _AutoPicked()),
                  scheme: scheme,
                  theme: theme,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                // Verified providers
                ..._filtered.map(
                  (p) => _PickerTile(
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: scheme.tertiaryContainer,
                      backgroundImage: p.logoUrl != null
                          ? NetworkImage(p.logoUrl!)
                          : null,
                      child: p.logoUrl == null
                          ? Text(
                              p.businessName[0].toUpperCase(),
                              style: TextStyle(
                                color: scheme.onTertiaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    title: p.businessName,
                    subtitle: p.address,
                    categoryChip: Chip(
                      label: Text(
                        _categoryLabel(l10n, p.category),
                        style: TextStyle(
                          fontSize: 11,
                          color: scheme.onTertiaryContainer,
                        ),
                      ),
                      backgroundColor: scheme.tertiaryContainer,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      side: BorderSide.none,
                    ),
                    isSelected: widget.currentProvider?.id == p.id,
                    onSelect: () => Navigator.pop(context, _ProviderPicked(p)),
                    scheme: scheme,
                    theme: theme,
                  ),
                ),
                // Become a Provider CTA
                const Divider(height: 24, indent: 16, endIndent: 16),
                ListTile(
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: scheme.secondaryContainer,
                    child: Icon(
                      Icons.storefront_rounded,
                      color: scheme.onSecondaryContainer,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    l10n.becomeProvider,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: scheme.primary,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.becomeProvider);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _categoryLabel(AppLocalizations l10n, BusinessCategory cat) {
    switch (cat) {
      case BusinessCategory.grocery:
        return l10n.providerCategoryGrocery;
      case BusinessCategory.household:
        return l10n.providerCategoryHousehold;
      case BusinessCategory.electronics:
        return l10n.providerCategoryElectronics;
      case BusinessCategory.clothing:
        return l10n.providerCategoryClothing;
      case BusinessCategory.restaurant:
        return l10n.providerCategoryRestaurant;
      case BusinessCategory.other:
        return l10n.providerCategoryOther;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PickerTile — lightweight selectable row in the picker sheet
// ─────────────────────────────────────────────────────────────────────────────

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onSelect,
    required this.scheme,
    required this.theme,
    this.categoryChip,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onSelect;
  final ColorScheme scheme;
  final ThemeData theme;
  final Widget? categoryChip;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: Row(
        children: [
          Flexible(
            child: Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isSelected) ...[
            const SizedBox(width: 6),
            Icon(Icons.check_circle_rounded, size: 16, color: scheme.primary),
          ],
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          if (categoryChip != null) ...[
            const SizedBox(height: 2),
            categoryChip!,
          ],
        ],
      ),
      isThreeLine: categoryChip != null,
      onTap: onSelect,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────

class _PresetOption {
  const _PresetOption({required this.value, required this.labelKey});

  final String value;
  final String labelKey;
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
    );
  }
}
