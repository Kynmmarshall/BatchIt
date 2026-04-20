import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/providers/batch_provider.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:batchit/widgets/common/app_primary_button.dart';
import 'package:batchit/widgets/common/app_screen_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class JoinBatchScreen extends StatefulWidget {
  const JoinBatchScreen({super.key, required this.batchId});

  final String batchId;

  @override
  State<JoinBatchScreen> createState() => _JoinBatchScreenState();
}

class _JoinBatchScreenState extends State<JoinBatchScreen> {
  final _quantityController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.joinBatch)),
      body: AppScreenContainer(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.quantity),
                ),
                const SizedBox(height: AppSpacing.md),
                AppPrimaryButton(
                  label: l10n.submit,
                  icon: Icons.check_circle_outline,
                  onPressed: () {
                    final value = double.tryParse(_quantityController.text.trim());
                    if (value == null || value <= 0) {
                      return;
                    }
                    context
                        .read<BatchProvider>()
                        .joinBatch(batchId: widget.batchId, quantityKg: value);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.joinedBatch)),
                    );
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
