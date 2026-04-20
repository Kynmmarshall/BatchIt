import 'package:batchit/core/router/app_routes.dart';
import 'package:batchit/core/utils/formatters.dart';
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/providers/batch_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BatchDetailsScreen extends StatelessWidget {
  const BatchDetailsScreen({super.key, required this.batchId});

  final String batchId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final batch = context.watch<BatchProvider>().findById(batchId);

    if (batch == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.batchDetails)),
        body: const Center(child: Text('Batch not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.batchDetails)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(batch.productName, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('${formatKg(batch.currentQuantityKg)} / ${formatKg(batch.bulkSizeKg)}'),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: batch.progress),
            const SizedBox(height: 16),
            Text('${l10n.location}: ${batch.locationName}'),
            Text('${l10n.hub}: ${batch.hubName}'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.joinBatch,
                    arguments: batchId,
                  );
                },
                child: Text(l10n.joinBatch),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
