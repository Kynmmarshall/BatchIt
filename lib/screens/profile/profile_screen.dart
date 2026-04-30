import 'package:batchit/core/app_routes.dart';
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/models/order.dart';
import 'package:batchit/providers/app_settings_provider.dart';
import 'package:batchit/providers/auth_provider.dart';
import 'package:batchit/providers/order_provider.dart';
import 'package:batchit/screens/orders/my_orders_screen.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:batchit/widgets/app_screen_container.dart';
import 'package:batchit/widgets/app_staggered_fade.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  final ImagePicker _imagePicker = ImagePicker();
  XFile? _pickedProfileImage;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.read<AuthProvider>();
    final l10n = AppLocalizations.of(context)!;

    final fullName = (auth.user?.name ?? l10n.profileDefaultName).trim();
    final parts = fullName.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();

    final firstName = parts.isNotEmpty ? parts.first : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    if (_firstNameController.text.isEmpty) _firstNameController.text = firstName;
    if (_lastNameController.text.isEmpty) _lastNameController.text = lastName;
    if (_emailController.text.isEmpty) _emailController.text = auth.user?.email ?? l10n.profileDefaultEmail;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleEditOrSave() {
    if (!_isEditing) {
      setState(() => _isEditing = true);
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;
    if (password.isNotEmpty || confirm.isNotEmpty) {
      if (password != confirm) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.confirmPassword)),
        );
        return;
      }
    }

    setState(() => _isEditing = false);
  }

  Future<void> _pickProfileImage() async {
    if (!_isEditing) return;

    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
    );
    if (!mounted || picked == null) return;

    setState(() => _pickedProfileImage = picked);
  }

  ImageProvider? _profileImageProvider() {
    final xfile = _pickedProfileImage;
    if (xfile == null) return null;

    if (kIsWeb) return NetworkImage(xfile.path);
    return FileImage(File(xfile.path));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<AppSettingsProvider>();
    final orders = context.watch<OrderProvider>().orders;

    final userName = auth.user?.name ?? l10n.profileDefaultName;
    final userEmail = auth.user?.email ?? l10n.profileDefaultEmail;
    final localeLabel = settings.locale.languageCode == 'fr' ? l10n.french : l10n.english;
    final themeLabel = settings.themeMode == ThemeMode.dark ? l10n.dark : l10n.light;
    final totalOrders = orders.length;
    final completedOrders = orders.where((order) => order.status == OrderStatus.completed).length;

    final displayName = auth.user?.name ?? l10n.profileDefaultName;
    final displayEmail = auth.user?.email ?? l10n.profileDefaultEmail;
    final profileImage = _profileImageProvider();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile)),
      body: AppScreenContainer(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppStaggeredFade(
                index: 0,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: _isEditing ? _pickProfileImage : null,
                          borderRadius: BorderRadius.circular(999),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                backgroundImage: profileImage,
                                child: profileImage == null
                                    ? Icon(
                                        Icons.person_rounded,
                                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                                      )
                                    : null,
                              ),
                              if (_isEditing)
                                Positioned(
                                  right: -2,
                                  bottom: -2,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Theme.of(context).colorScheme.surface,
                                        width: 2,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(6),
                                      child: Icon(
                                        Icons.edit_rounded,
                                        size: 14,
                                        color: Theme.of(context).colorScheme.onPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(displayName, style: Theme.of(context).textTheme.titleLarge),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(displayEmail, style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppStaggeredFade(
                index: 1,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _firstNameController,
                            enabled: _isEditing,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'First Name',
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'First name is required' : null,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextFormField(
                            controller: _lastNameController,
                            enabled: _isEditing,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Last Name',
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Last name is required' : null,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextFormField(
                            controller: _emailController,
                            enabled: _isEditing,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: l10n.email,
                              prefixIcon: const Icon(Icons.email_outlined),
                            ),
                            validator: (v) {
                              final value = (v ?? '').trim();
                              if (value.isEmpty) return 'Email is required';
                              if (!value.contains('@')) return 'Enter a valid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextFormField(
                            controller: _passwordController,
                            enabled: _isEditing,
                            obscureText: true,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: l10n.password,
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextFormField(
                            controller: _confirmPasswordController,
                            enabled: _isEditing,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: l10n.confirmPassword,
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _toggleEditOrSave,
                              icon: Icon(_isEditing ? Icons.check_rounded : Icons.edit_rounded),
                              label: Text(_isEditing ? l10n.submit : 'Edit'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppStaggeredFade(
                index: 2,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.changeLanguage, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.xs),
                        SegmentedButton<String>(
                          segments: [
                            ButtonSegment<String>(value: 'en', label: Text(l10n.english)),
                            ButtonSegment<String>(value: 'fr', label: Text(l10n.french)),
                          ],
                          selected: {settings.locale.languageCode},
                          onSelectionChanged: (value) {
                            context.read<AppSettingsProvider>().setLocale(Locale(value.first));
                          },
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(l10n.switchTheme),
                          value: settings.themeMode == ThemeMode.dark,
                          onChanged: (_) {
                            context.read<AppSettingsProvider>().toggleTheme();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppStaggeredFade(
                index: 3,
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.read<AuthProvider>().logout();
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: Text(l10n.logout),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleProvider(String providerId, bool selected) {
    if (selected) {
      _followedProviderIds.add(providerId);
    } else {
      _followedProviderIds.remove(providerId);
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return 'B';
    }

    final buffer = StringBuffer();
    for (final part in parts.take(2)) {
      if (part.isNotEmpty) {
        buffer.write(part[0].toUpperCase());
      }
    }

    final initials = buffer.toString();
    return initials.isEmpty ? 'B' : initials;
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      color: scheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
