import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.chatTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 52,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.chatTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.chatLead,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Chip(
                avatar: Icon(Icons.schedule_rounded,
                    size: 16, color: scheme.onSecondaryContainer),
                label: Text(
                  l10n.comingSoon,
                  style: TextStyle(color: scheme.onSecondaryContainer),
                ),
                backgroundColor: scheme.secondaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
