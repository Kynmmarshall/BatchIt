import 'package:batchit/core/app_routes.dart';
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/providers/batch_provider.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:batchit/widgets/app_screen_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<BatchProvider>().loadMyCreatedBatches();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final batchProvider = context.watch<BatchProvider>();
    final scheme = Theme.of(context).colorScheme;

    final batches = batchProvider.myCreatedBatches;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.chatTitle)),
      body: AppScreenContainer(
        child: batchProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : batches.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.chat_bubble_outline_rounded,
                              size: 52, color: scheme.onPrimaryContainer),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(l10n.chatTitle,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Create or join a batch to access its group chat.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        FilledButton.icon(
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.createBatch),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Create a Batch'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: batches.length,
                    itemBuilder: (_, i) {
                      final batch = batches[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: scheme.primaryContainer,
                            child: Icon(Icons.inventory_2_outlined,
                                color: scheme.onPrimaryContainer),
                          ),
                          title: Text(batch.productName),
                          subtitle: Text(batch.locationName,
                              style: TextStyle(color: scheme.onSurfaceVariant)),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.batchChat,
                            arguments: {
                              'batchId': batch.id,
                              'batchName': batch.productName,
                            },
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
