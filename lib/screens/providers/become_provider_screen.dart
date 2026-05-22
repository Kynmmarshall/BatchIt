import 'dart:io';
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/models/provider_profile.dart';
import 'package:batchit/providers/auth_provider.dart';
import 'package:batchit/providers/provider_provider.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:batchit/widgets/app_primary_button.dart';
import 'package:batchit/widgets/app_screen_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

// ─── Step 1 controllers: Business Info ───────────────────────────────────────
// ─── Step 2 controllers: Contact & Location ──────────────────────────────────
// ─── Step 3 data: Documents & Description ────────────────────────────────────

class BecomeProviderScreen extends StatefulWidget {
  const BecomeProviderScreen({super.key});

  @override
  State<BecomeProviderScreen> createState() => _BecomeProviderScreenState();
}

class _BecomeProviderScreenState extends State<BecomeProviderScreen> {
  final _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 3;

  // Step 1 – Business Info
  final _step1Key = GlobalKey<FormState>();
  final _businessNameCtrl = TextEditingController();
  final _ownerNameCtrl = TextEditingController();
  final _regNumberCtrl = TextEditingController();
  BusinessCategory _selectedCategory = BusinessCategory.grocery;

  // Step 2 – Contact & Location
  final _step2Key = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();

  // Step 3 – Documents & Description
  final _step3Key = GlobalKey<FormState>();
  final _descriptionCtrl = TextEditingController();
  final List<File> _documents = [];
  File? _logo;
  final ImagePicker _picker = ImagePicker();
  bool _editingExistingProfile = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill email from authenticated user
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _emailCtrl.text = user.email;
      _ownerNameCtrl.text = user.displayName;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final provider = context.read<ProviderProvider>();
      await provider.loadMyProfile();
      if (!mounted) return;
      final profile = provider.myProfile;
      if (profile != null) {
        _applyProfileValues(profile);
      }
    });
  }

  void _applyProfileValues(ProviderProfile profile) {
    _businessNameCtrl.text = profile.businessName;
    _ownerNameCtrl.text = profile.ownerName;
    _regNumberCtrl.text = profile.registrationNumber;
    _phoneCtrl.text = profile.phone;
    _emailCtrl.text = profile.email;
    _addressCtrl.text = profile.address;
    _latCtrl.text = profile.latitude?.toString() ?? '';
    _lngCtrl.text = profile.longitude?.toString() ?? '';
    _descriptionCtrl.text = profile.description;
    _selectedCategory = profile.category;
  }

  void _enterEditMode(ProviderProfile profile) {
    _applyProfileValues(profile);
    setState(() {
      _editingExistingProfile = true;
      _currentStep = 0;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) return;
      _pageController.jumpToPage(0);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _businessNameCtrl.dispose();
    _ownerNameCtrl.dispose();
    _regNumberCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  void _goNext() {
    final valid = switch (_currentStep) {
      0 => _step1Key.currentState?.validate() ?? false,
      1 => _step2Key.currentState?.validate() ?? false,
      _ => true,
    };
    if (!valid) return;

    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goBack() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _pickDocument() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _documents.add(File(file.path)));
    }
  }

  Future<void> _pickLogo() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file != null) {
      setState(() => _logo = File(file.path));
    }
  }

  void _removeDocument(int index) {
    setState(() => _documents.removeAt(index));
  }

  Future<void> _submit() async {
    if (!(_step3Key.currentState?.validate() ?? false)) return;

    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<ProviderProvider>();

    try {
      if (provider.hasProfile) {
        await provider.updateMyProviderProfile(
          businessName: _businessNameCtrl.text.trim(),
          ownerName: _ownerNameCtrl.text.trim(),
          category: _selectedCategory,
          registrationNumber: _regNumberCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
          latitude: double.tryParse(_latCtrl.text.trim()),
          longitude: double.tryParse(_lngCtrl.text.trim()),
          description: _descriptionCtrl.text.trim(),
        );
      } else {
        await provider.submitProviderProfile(
          businessName: _businessNameCtrl.text.trim(),
          ownerName: _ownerNameCtrl.text.trim(),
          category: _selectedCategory,
          registrationNumber: _regNumberCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
          latitude: double.tryParse(_latCtrl.text.trim()),
          longitude: double.tryParse(_lngCtrl.text.trim()),
          description: _descriptionCtrl.text.trim(),
          documents: _documents.isEmpty ? null : _documents,
          logo: _logo,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.providerSubmitSuccess)));
      if (provider.hasProfile) {
        setState(() => _editingExistingProfile = false);
      } else {
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.providerSubmitError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final providerState = context.watch<ProviderProvider>();

    if (providerState.hasProfile && !_editingExistingProfile) {
      return _ProfileStatusView(
        profile: providerState.myProfile!,
        onEdit: () => _enterEditMode(providerState.myProfile!),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(providerState.hasProfile ? 'My Provider Profile' : l10n.becomeProvider),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: _StepProgressBar(
            current: _currentStep,
            total: _totalSteps,
          ),
        ),
      ),
      body: AppScreenContainer(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentStep = i),
                children: [
                  _Step1BusinessInfo(
                    formKey: _step1Key,
                    businessNameCtrl: _businessNameCtrl,
                    ownerNameCtrl: _ownerNameCtrl,
                    regNumberCtrl: _regNumberCtrl,
                    selectedCategory: _selectedCategory,
                    onCategoryChanged: (c) =>
                        setState(() => _selectedCategory = c),
                  ),
                  _Step2ContactLocation(
                    formKey: _step2Key,
                    phoneCtrl: _phoneCtrl,
                    emailCtrl: _emailCtrl,
                    addressCtrl: _addressCtrl,
                    latCtrl: _latCtrl,
                    lngCtrl: _lngCtrl,
                  ),
                  _Step3DocumentsDescription(
                    formKey: _step3Key,
                    descriptionCtrl: _descriptionCtrl,
                    documents: _documents,
                    logo: _logo,
                    onPickDocument: _pickDocument,
                    onRemoveDocument: _removeDocument,
                    onPickLogo: _pickLogo,
                  ),
                ],
              ),
            ),
            _StepNavBar(
              currentStep: _currentStep,
              totalSteps: _totalSteps,
              isSubmitting: providerState.isSubmitting,
              onBack: _goBack,
              onNext: _goNext,
              onSubmit: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Step 1: Business Info ────────────────────────────────────────────────────

class _Step1BusinessInfo extends StatelessWidget {
  const _Step1BusinessInfo({
    required this.formKey,
    required this.businessNameCtrl,
    required this.ownerNameCtrl,
    required this.regNumberCtrl,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController businessNameCtrl;
  final TextEditingController ownerNameCtrl;
  final TextEditingController regNumberCtrl;
  final BusinessCategory selectedCategory;
  final ValueChanged<BusinessCategory> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        children: [
          _StepHeader(
            icon: Icons.storefront_rounded,
            title: l10n.providerStep1Title,
            subtitle: l10n.providerStep1Subtitle,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: businessNameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: l10n.providerBusinessName,
              hintText: l10n.providerBusinessNameHint,
              prefixIcon: const Icon(Icons.business_rounded),
            ),
            validator: _required,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: ownerNameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: l10n.providerOwnerName,
              hintText: l10n.providerOwnerNameHint,
              prefixIcon: const Icon(Icons.person_rounded),
            ),
            validator: _required,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: regNumberCtrl,
            decoration: InputDecoration(
              labelText: l10n.providerRegistrationNumber,
              hintText: l10n.providerRegistrationNumberHint,
              prefixIcon: const Icon(Icons.badge_rounded),
            ),
            validator: _required,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.providerCategory,
            style: theme.textTheme.titleSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: BusinessCategory.values.map((cat) {
              final selected = cat == selectedCategory;
              return ChoiceChip(
                label: Text(_categoryLabel(l10n, cat)),
                selected: selected,
                onSelected: (_) => onCategoryChanged(cat),
                selectedColor: scheme.primary,
                labelStyle: TextStyle(
                  color: selected ? scheme.onPrimary : scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide(
                  color: selected ? scheme.primary : scheme.outlineVariant,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Step 2: Contact & Location ───────────────────────────────────────────────

class _Step2ContactLocation extends StatefulWidget {
  const _Step2ContactLocation({
    required this.formKey,
    required this.phoneCtrl,
    required this.emailCtrl,
    required this.addressCtrl,
    required this.latCtrl,
    required this.lngCtrl,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController phoneCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController addressCtrl;
  final TextEditingController latCtrl;
  final TextEditingController lngCtrl;

  @override
  State<_Step2ContactLocation> createState() => _Step2ContactLocationState();
}

class _Step2ContactLocationState extends State<_Step2ContactLocation> {
  bool _locating = false;

  Future<void> _useMyLocation() async {
    setState(() => _locating = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
        }
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (mounted) {
        widget.latCtrl.text = pos.latitude.toStringAsFixed(6);
        widget.lngCtrl.text = pos.longitude.toStringAsFixed(6);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not get location')),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Form(
      key: widget.formKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        children: [
          _StepHeader(
            icon: Icons.location_on_rounded,
            title: l10n.providerStep2Title,
            subtitle: l10n.providerStep2Subtitle,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: widget.phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: l10n.providerPhone,
              hintText: l10n.providerPhoneHint,
              prefixIcon: const Icon(Icons.phone_rounded),
            ),
            validator: _required,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: widget.emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: l10n.providerBusinessEmail,
              prefixIcon: const Icon(Icons.email_rounded),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return l10n.providerFieldRequired;
              if (!v.contains('@')) return l10n.providerFieldRequired;
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: widget.addressCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: l10n.providerAddress,
              hintText: l10n.providerAddressHint,
              prefixIcon: const Icon(Icons.place_rounded),
            ),
            validator: _required,
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.my_location_rounded,
                        size: 18, color: scheme.primary),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        l10n.providerGpsTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    FilledButton.tonalIcon(
                      style: FilledButton.styleFrom(
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm, vertical: 6),
                      ),
                      onPressed: _locating ? null : _useMyLocation,
                      icon: _locating
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.gps_fixed_rounded, size: 14),
                      label: Text(
                        'Use My Location',
                        style: theme.textTheme.labelSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.providerGpsNote,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: widget.latCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.\-]')),
                        ],
                        decoration: InputDecoration(
                          labelText: l10n.providerLatitude,
                          hintText: '33.5731',
                        ),
                        validator: _optionalCoord,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: TextFormField(
                        controller: widget.lngCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.\-]')),
                        ],
                        decoration: InputDecoration(
                          labelText: l10n.providerLongitude,
                          hintText: '-7.5898',
                        ),
                        validator: _optionalCoord,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 3: Documents & Description ─────────────────────────────────────────

class _Step3DocumentsDescription extends StatelessWidget {
  const _Step3DocumentsDescription({
    required this.formKey,
    required this.descriptionCtrl,
    required this.documents,
    required this.logo,
    required this.onPickDocument,
    required this.onRemoveDocument,
    required this.onPickLogo,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController descriptionCtrl;
  final List<File> documents;
  final File? logo;
  final VoidCallback onPickDocument;
  final ValueChanged<int> onRemoveDocument;
  final VoidCallback onPickLogo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        children: [
          _StepHeader(
            icon: Icons.folder_open_rounded,
            title: l10n.providerStep3Title,
            subtitle: l10n.providerStep3Subtitle,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: descriptionCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: l10n.providerDescription,
              hintText: l10n.providerDescriptionHint,
              alignLabelWithHint: true,
            ),
            validator: _required,
          ),
          const SizedBox(height: AppSpacing.lg),
          // Logo picker
          Text(
            l10n.providerUploadLogo,
            style: theme.textTheme.titleSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          GestureDetector(
            onTap: onPickLogo,
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: logo != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(logo!, fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_rounded,
                            color: scheme.primary, size: 32),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          l10n.providerUploadLogoHint,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Document picker
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.providerUploadDocs,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              TextButton.icon(
                onPressed: onPickDocument,
                icon: const Icon(Icons.attach_file_rounded, size: 18),
                label: Text(l10n.providerAddDoc),
              ),
            ],
          ),
          Text(
            l10n.providerUploadDocsHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          if (documents.isEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Center(
                child: Text(
                  l10n.providerNoDocs,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: AppSpacing.xs),
            ...documents.asMap().entries.map((entry) {
              final i = entry.key;
              final file = entry.value;
              final name = file.path.split('/').last;
              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: ListTile(
                  dense: true,
                  leading: Icon(Icons.insert_drive_file_rounded,
                      color: scheme.primary),
                  title: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: () => onRemoveDocument(i),
                  ),
                ),
              );
            }),
          ],
          const SizedBox(height: AppSpacing.md),
          // Legal notice
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 18, color: scheme.onTertiaryContainer),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    l10n.providerLegalNote,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onTertiaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Profile Status View (already submitted) ──────────────────────────────────

class _ProfileStatusView extends StatelessWidget {
  const _ProfileStatusView({required this.profile, required this.onEdit});

  final ProviderProfile profile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final (icon, color, label) = switch (profile.status) {
      ProviderStatus.verified => (
          Icons.verified_rounded,
          Colors.green,
          l10n.providerStatusVerified,
        ),
      ProviderStatus.rejected => (
          Icons.cancel_rounded,
          scheme.error,
          l10n.providerStatusRejected,
        ),
      ProviderStatus.pending => (
          Icons.hourglass_top_rounded,
          scheme.primary,
          l10n.providerStatusPending,
        ),
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.becomeProvider)),
      body: AppScreenContainer(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 72, color: color),
              const SizedBox(height: AppSpacing.md),
              Text(
                label,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                profile.businessName,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                profile.address,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              if (profile.isPending)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text(
                      l10n.providerPendingNote,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: AppPrimaryButton(
                  label: 'My Provider Profile',
                  icon: Icons.edit_rounded,
                  onPressed: onEdit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: scheme.onPrimaryContainer, size: 28),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepProgressBar extends StatelessWidget {
  const _StepProgressBar({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final progress = (current + 1) / total;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: scheme.outlineVariant,
              valueColor: AlwaysStoppedAnimation(scheme.primary),
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Step ${current + 1} of $total',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _StepNavBar extends StatelessWidget {
  const _StepNavBar({
    required this.currentStep,
    required this.totalSteps,
    required this.isSubmitting,
    required this.onBack,
    required this.onNext,
    required this.onSubmit,
  });

  final int currentStep;
  final int totalSteps;
  final bool isSubmitting;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLast = currentStep == totalSteps - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          if (currentStep > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: isSubmitting ? null : onBack,
                child: Text(l10n.providerBack),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            flex: 2,
            child: AppPrimaryButton(
              label: isLast ? l10n.providerSubmit : l10n.providerNext,
              onPressed: isSubmitting ? null : (isLast ? onSubmit : onNext),
              isLoading: isSubmitting,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Validators ───────────────────────────────────────────────────────────────

String? _required(String? v) {
  if (v == null || v.trim().isEmpty) return 'Required';
  return null;
}

String? _optionalCoord(String? v) {
  if (v == null || v.trim().isEmpty) return null;
  if (double.tryParse(v.trim()) == null) return 'Invalid number';
  return null;
}

String _categoryLabel(AppLocalizations l10n, BusinessCategory cat) {
  return switch (cat) {
    BusinessCategory.grocery => l10n.providerCategoryGrocery,
    BusinessCategory.household => l10n.providerCategoryHousehold,
    BusinessCategory.electronics => l10n.providerCategoryElectronics,
    BusinessCategory.clothing => l10n.providerCategoryClothing,
    BusinessCategory.restaurant => l10n.providerCategoryRestaurant,
    BusinessCategory.other => l10n.providerCategoryOther,
  };
}
