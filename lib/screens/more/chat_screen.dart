import 'package:batchit/core/app_routes.dart';
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/models/batch.dart';
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
      if (!mounted) return;
      final provider = context.read<BatchProvider>();
      provider.loadMyCreatedBatches();
      provider.loadMyJoinedBatches();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final batchProvider = context.watch<BatchProvider>();
    final scheme = Theme.of(context).colorScheme;

    // Merge created + joined, deduplicating by ID.
    final createdIds = batchProvider.myCreatedBatches.map((b) => b.id).toSet();
    final created = batchProvider.myCreatedBatches;
    final joined = batchProvider.myJoinedBatches
        .where((b) => !createdIds.contains(b.id))
        .toList();
    final allBatches = [...created, ...joined];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.chatTitle)),
      body: AppScreenContainer(
        child: batchProvider.isLoading && allBatches.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : allBatches.isEmpty
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
                : ListView(
                    children: [
                      if (created.isNotEmpty) ...[
                        _SectionHeader(label: 'Batches I Created'),
                        ...created.map((b) => _BatchChatTile(batch: b)),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                      if (joined.isNotEmpty) ...[
                        _SectionHeader(label: 'Batches I Joined'),
                        ...joined.map((b) => _BatchChatTile(batch: b)),
                      ],
                    ],
                  ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
      ),
    );
  }
}

class _BatchChatTile extends StatelessWidget {
  const _BatchChatTile({required this.batch});

  final Batch batch;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          child: Icon(Icons.inventory_2_outlined,
              color: scheme.onPrimaryContainer),
        ),
        title: Text(batch.productName),
        subtitle: Text(
          batch.locationName,
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
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
  }
}
