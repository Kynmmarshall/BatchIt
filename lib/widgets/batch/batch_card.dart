import 'package:batchit/core/utils/formatters.dart';
import 'package:batchit/models/batch.dart';
import 'package:flutter/material.dart';

class BatchCard extends StatelessWidget {
  const BatchCard({
    super.key,
    required this.batch,
    required this.joinLabel,
    required this.onTap,
  });

  final Batch batch;
  final String joinLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      batch.productName,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  if (batch.isFull)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'FULL',
                        style: theme.textTheme.labelSmall,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text('${formatKg(batch.currentQuantityKg)} / ${formatKg(batch.bulkSizeKg)}'),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: batch.progress),
              const SizedBox(height: 12),
              Text(batch.locationName, style: theme.textTheme.bodySmall),
              Text(batch.hubName, style: theme.textTheme.bodySmall),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonal(
                  onPressed: onTap,
                  child: Text(joinLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
