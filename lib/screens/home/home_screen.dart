import 'package:batchit/core/router/app_routes.dart';
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/providers/batch_provider.dart';
import 'package:batchit/widgets/batch/batch_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BatchProvider>().loadNearbyBatches();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final batchProvider = context.watch<BatchProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.home),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.nearbyBatches, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text('${l10n.activeBatches}: ${batchProvider.batches.length}'),
            const SizedBox(height: 12),
            Expanded(
              child: batchProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      itemCount: batchProvider.batches.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final batch = batchProvider.batches[index];
                        return BatchCard(
                          batch: batch,
                          joinLabel: l10n.join,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.batchDetails,
                              arguments: batch.id,
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
