import 'package:batchit/core/router/app_routes.dart';
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/providers/batch_provider.dart';
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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.createBatch)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _productController,
                decoration: InputDecoration(labelText: l10n.productName),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? l10n.productName : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bulkController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.bulkSize),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? l10n.bulkSize : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: l10n.location),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? l10n.location : null,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _createBatch,
                child: Text(l10n.submit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
