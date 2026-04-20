import 'package:batchit/core/router/app_routes.dart';
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/providers/batch_provider.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:batchit/widgets/common/app_primary_button.dart';
import 'package:batchit/widgets/common/app_screen_container.dart';
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
  final _bulkController = TextEditingController(text: '50');

  @override
  void dispose() {
    _productController.dispose();
    _locationController.dispose();
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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.createBatch)),
      body: AppScreenContainer(
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                l10n.createBatch,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.welcomeSubtitle,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _productController,
                        decoration: InputDecoration(labelText: l10n.productName),
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? l10n.productName : null,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _bulkController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: l10n.bulkSize),
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? l10n.bulkSize : null,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _locationController,
                        decoration: InputDecoration(labelText: l10n.location),
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? l10n.location : null,
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
            ],
          ),
        ),
      ),
    );
  }
}
