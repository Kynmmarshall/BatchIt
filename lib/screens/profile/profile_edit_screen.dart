import 'dart:io';
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/providers/auth_provider.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:batchit/widgets/app_primary_button.dart';
import 'package:batchit/widgets/app_screen_container.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  File? _selectedImage;
  bool _isSaving = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await context.read<AuthProvider>().updateUserProfile(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            profileImage: _selectedImage,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.successProfileUpdated)),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorProfileUpdate)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileEditTitle)),
      body: AppScreenContainer(
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!) as ImageProvider
                            : (user?.avatarUrl != null
                                ? NetworkImage(user!.avatarUrl!)
                                : null),
                        child: _selectedImage == null && user?.avatarUrl == null
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Center(
                child: Text(
                  l10n.profileEditImageHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              TextFormField(
                controller: _firstNameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: l10n.profileFirstName,
                  hintText: l10n.profileFirstNameHint,
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? l10n.profileEditValidationRequired
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _lastNameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: l10n.profileLastName,
                  hintText: l10n.profileLastNameHint,
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? l10n.profileEditValidationRequired
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                initialValue: user?.email ?? '',
                readOnly: true,
                decoration: InputDecoration(
                  labelText: l10n.email,
                  helperText: l10n.profileEmailReadOnly,
                  suffixIcon: const Icon(Icons.lock_outline, size: 18),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppPrimaryButton(
                label: l10n.profileEditSave,
                onPressed: _isSaving ? null : _saveProfile,
                isLoading: _isSaving,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
