import 'package:batchit/core/app_routes.dart';
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/models/provider_profile.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:flutter/material.dart';

/// Reusable card showing a verified provider's key details.
/// Used in ProviderDiscoveryScreen and (Module 3) batch-creation picker.
///
/// [isFollowing] and [onFollowToggle] are optional — omit them when the card
/// is used inside a picker sheet where follow is irrelevant.
class ProviderCard extends StatelessWidget {
  const ProviderCard({
    super.key,
    required this.provider,
    this.isFollowing = false,
    this.onFollowToggle,
    this.onTap,
    this.trailing,
  });

  final ProviderProfile provider;
  final bool isFollowing;
  final VoidCallback? onFollowToggle;
  final VoidCallback? onTap;

  /// Optional override for the trailing action area (e.g. a "Select" button
  /// in the batch-creation picker). When null the Follow button is shown.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ??
            () => Navigator.pushNamed(
                  context,
                  AppRoutes.providerDetail,
                  arguments: provider.id,
                ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header: avatar + name + badge ──────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProviderAvatar(provider: provider, scheme: scheme),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                provider.businessName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xxs),
                            if (provider.isVerified)
                              Icon(Icons.verified_rounded,
                                  size: 16, color: scheme.primary),
                          ],
                        ),
                        Text(
                          provider.ownerName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Category chip
                  _CategoryChip(
                    label: _categoryLabel(l10n, provider.category),
                    scheme: scheme,
                    theme: theme,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              // ── Info row: address ───────────────────────────────────────
              Row(
                children: [
                  Icon(Icons.place_rounded,
                      size: 14, color: scheme.onSurfaceVariant),
                  const SizedBox(width: AppSpacing.xxs),
                  Expanded(
                    child: Text(
                      provider.address,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              if (provider.description.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  provider.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: AppSpacing.sm),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.xs),

              // ── Action row ──────────────────────────────────────────────
              Row(
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 6),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => _launchContact(context, provider),
                    icon: const Icon(Icons.phone_rounded, size: 16),
                    label: Text(l10n.providerCardContact,
                        style: theme.textTheme.labelSmall),
                  ),
                  const Spacer(),
                  trailing ??
                      FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm, vertical: 6),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: onFollowToggle,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isFollowing
                                  ? Icons.check_rounded
                                  : Icons.add_rounded,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isFollowing
                                  ? l10n.providerCardFollowing
                                  : l10n.providerCardFollow,
                              style: theme.textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchContact(BuildContext context, ProviderProfile p) {
    // Phone / email contact — Module 4 will deep-link to dialer/mail app.
    // For now show a bottom sheet with contact info.
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => _ContactSheet(provider: p),
    );
  }
}

// ─── Private sub-widgets ──────────────────────────────────────────────────────

class _ProviderAvatar extends StatelessWidget {
  const _ProviderAvatar({required this.provider, required this.scheme});

  final ProviderProfile provider;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    if (provider.logoUrl != null && provider.logoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(provider.logoUrl!),
        backgroundColor: scheme.secondaryContainer,
      );
    }
    return CircleAvatar(
      radius: 24,
      backgroundColor: scheme.secondaryContainer,
      child: Text(
        provider.businessName.isNotEmpty
            ? provider.businessName[0].toUpperCase()
            : '?',
        style: TextStyle(
          color: scheme.onSecondaryContainer,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.scheme,
    required this.theme,
  });

  final String label;
  final ColorScheme scheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: scheme.onTertiaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ContactSheet extends StatelessWidget {
  const _ContactSheet({required this.provider});

  final ProviderProfile provider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(provider.businessName,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: AppSpacing.md),
            _ContactRow(
              icon: Icons.phone_rounded,
              label: provider.phone,
              scheme: scheme,
              theme: theme,
            ),
            const SizedBox(height: AppSpacing.sm),
            _ContactRow(
              icon: Icons.email_rounded,
              label: provider.email,
              scheme: scheme,
              theme: theme,
            ),
            const SizedBox(height: AppSpacing.sm),
            _ContactRow(
              icon: Icons.place_rounded,
              label: provider.address,
              scheme: scheme,
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.scheme,
    required this.theme,
  });

  final IconData icon;
  final String label;
  final ColorScheme scheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: scheme.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

String _categoryLabel(AppLocalizations l10n, BusinessCategory cat) {
  return switch (cat) {
    BusinessCategory.grocery => l10n.providerCategoryGrocery,
    BusinessCategory.household => l10n.providerCategoryHousehold,
    BusinessCategory.electronics => l10n.providerCategoryElectronics,
    BusinessCategory.clothing => l10n.providerCategoryClothing,
    BusinessCategory.restaurant => l10n.providerCategoryRestaurant,
    BusinessCategory.other => l10n.providerCategoryOther,
  };
}
