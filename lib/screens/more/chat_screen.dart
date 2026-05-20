import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:batchit/widgets/app_screen_container.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.chatTitle)),
      body: AppScreenContainer(
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.storefront_outlined)),
                title: Text(l10n.providerAinSebaa),
                subtitle: Text(l10n.chatProviderSubtitle),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.group_outlined)),
                title: Text(l10n.chatBatchGroupTitle),
                subtitle: Text(l10n.chatBatchGroupSubtitle),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: Center(
                child: Text(
                  l10n.chatLead,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
