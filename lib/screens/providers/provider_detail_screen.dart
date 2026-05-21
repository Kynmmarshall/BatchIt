import 'package:batchit/core/app_routes.dart';
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/models/provider_profile.dart';
import 'package:batchit/providers/provider_provider.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:batchit/widgets/app_primary_button.dart';
import 'package:batchit/widgets/app_screen_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Full-detail view for a single verified provider.
/// Receives the provider ID as a route argument (String).
class ProviderDetailScreen extends StatefulWidget {
  const ProviderDetailScreen({super.key, required this.providerId});

  final String providerId;

  @override
  State<ProviderDetailScreen> createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends State<ProviderDetailScreen> {
  bool _isFollowing = false;

  ProviderProfile? _resolve(ProviderProvider state) =>
      state.findById(widget.providerId);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = context.watch<ProviderProvider>();
    final provider = _resolve(state);

    if (state.isLoading && provider == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.providerDetailTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (provider == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.providerDetailTitle)),
        body: Center(child: Text(l10n.batchNotFound)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(provider.businessName),
        actions: [
          IconButton(
            icon: Icon(
              _isFollowing
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_none_rounded,
            ),
            tooltip: _isFollowing
                ? l10n.providerCardFollowing
                : l10n.providerCardFollow,
            onPressed: () => setState(() => _isFollowing = !_isFollowing),
          ),
        ],
      ),
      body: AppScreenContainer(
        child: ListView(
          children: [
            // ── Hero header ─────────────────────────────────────────────
            _HeroHeader(provider: provider),

            const SizedBox(height: AppSpacing.md),

            // ── Contact info ─────────────────────────────────────────────
            _SectionCard(
              icon: Icons.contact_phone_rounded,
              title: l10n.providerCardContact,
              children: [
                _InfoRow(
                  icon: Icons.person_rounded,
                  label: l10n.providerDetailOwner,
                  value: provider.ownerName,
                ),
                _InfoRow(
                  icon: Icons.phone_rounded,
                  label: l10n.providerPhone,
                  value: provider.phone,
                ),
                _InfoRow(
                  icon: Icons.email_rounded,
                  label: l10n.providerBusinessEmail,
                  value: provider.email,
                ),
                _InfoRow(
                  icon: Icons.badge_rounded,
                  label: l10n.providerDetailRegistration,
                  value: provider.registrationNumber,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            // ── Services & Products ──────────────────────────────────────
            _SectionCard(
              icon: Icons.inventory_2_rounded,
              title: l10n.providerDetailServices,
              children: [
                Text(
                  provider.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            // ── Business Location ────────────────────────────────────────
            _SectionCard(
              icon: Icons.location_on_rounded,
              title: l10n.providerDetailLocationSection,
              children: [
                _InfoRow(
                  icon: Icons.place_rounded,
                  label: l10n.providerAddress,
                  value: provider.address,
                ),
                if (provider.latitude != null && provider.longitude != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  _CoordinatesRow(provider: provider, l10n: l10n),
                  const SizedBox(height: AppSpacing.sm),
                  // Map placeholder — replaced by real map in Module 4
                  _MapPlaceholder(provider: provider, l10n: l10n),
                ],
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Primary CTA: Create Batch ─────────────────────────────────
            AppPrimaryButton(
              label: l10n.providerDetailCreateBatch,
              icon: Icons.add_task_rounded,
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.createBatch,
                arguments: provider.id,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // ── Secondary CTA: Contact ────────────────────────────────────
            AppPrimaryButton(
              label: l10n.providerDetailContactProvider,
              icon: Icons.phone_rounded,
              isSecondary: true,
              onPressed: () => _showContactSheet(context, provider, l10n),
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  void _showContactSheet(
    BuildContext context,
    ProviderProfile provider,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                provider.businessName,
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: AppSpacing.md),
              _ContactTile(
                  icon: Icons.phone_rounded, label: provider.phone, ctx: ctx),
              const SizedBox(height: AppSpacing.xs),
              _ContactTile(
                  icon: Icons.email_rounded, label: provider.email, ctx: ctx),
              const SizedBox(height: AppSpacing.xs),
              _ContactTile(
                  icon: Icons.place_rounded, label: provider.address, ctx: ctx),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Hero header ──────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.provider});

  final ProviderProfile provider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final categoryLabel = switch (provider.category) {
      BusinessCategory.grocery => l10n.providerCategoryGrocery,
      BusinessCategory.household => l10n.providerCategoryHousehold,
      BusinessCategory.electronics => l10n.providerCategoryElectronics,
      BusinessCategory.clothing => l10n.providerCategoryClothing,
      BusinessCategory.restaurant => l10n.providerCategoryRestaurant,
      BusinessCategory.other => l10n.providerCategoryOther,
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary.withValues(alpha: 0.12),
            scheme.secondaryContainer.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 36,
            backgroundColor: scheme.primary,
            backgroundImage: provider.logoUrl != null &&
                    provider.logoUrl!.isNotEmpty
                ? NetworkImage(provider.logoUrl!)
                : null,
            child: provider.logoUrl == null || provider.logoUrl!.isEmpty
                ? Text(
                    provider.businessName.isNotEmpty
                        ? provider.businessName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: scheme.onPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        provider.businessName,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    if (provider.isVerified)
                      Icon(Icons.verified_rounded,
                          color: scheme.primary, size: 20),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs, vertical: 2),
                      decoration: BoxDecoration(
                        color: scheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        categoryLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onTertiaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Icon(Icons.verified_rounded,
                        size: 12, color: Colors.green.shade600),
                    const SizedBox(width: 2),
                    Text(
                      l10n.providerStatusVerified,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section card ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: scheme.primary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ...children,
          ],
        ),
      ),
    );
  }
}

// ─── Info row ─────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: scheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                Text(value, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Coordinates row ──────────────────────────────────────────────────────────

class _CoordinatesRow extends StatelessWidget {
  const _CoordinatesRow({required this.provider, required this.l10n});

  final ProviderProfile provider;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      children: [
        _CoordChip(
          label: l10n.providerLatitude,
          value: provider.latitude!.toStringAsFixed(4),
          scheme: scheme,
          theme: theme,
        ),
        const SizedBox(width: AppSpacing.sm),
        _CoordChip(
          label: l10n.providerLongitude,
          value: provider.longitude!.toStringAsFixed(4),
          scheme: scheme,
          theme: theme,
        ),
      ],
    );
  }
}

class _CoordChip extends StatelessWidget {
  const _CoordChip({
    required this.label,
    required this.value,
    required this.scheme,
    required this.theme,
  });

  final String label;
  final String value;
  final ColorScheme scheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: scheme.onSurfaceVariant)),
          Text(value,
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ─── Map placeholder ──────────────────────────────────────────────────────────

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder({required this.provider, required this.l10n});

  final ProviderProfile provider;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        // Module 4 will launch the map view with this provider's coordinates.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${l10n.providerDetailViewOnMap} — coming in Module 4',
            ),
          ),
        );
      },
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Stack(
          children: [
            // Grid pattern to simulate a map tile
            CustomPaint(
              size: const Size(double.infinity, 140),
              painter: _MapGridPainter(color: scheme.outlineVariant),
            ),
            // Centered pin
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_pin, color: scheme.error, size: 40),
                  const SizedBox(height: AppSpacing.xxs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: 2),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Text(
                      provider.businessName,
                      style: theme.textTheme.labelSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            // "View on Map" button overlay
            Positioned(
              bottom: AppSpacing.xs,
              right: AppSpacing.xs,
              child: FilledButton.icon(
                onPressed: null,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.open_in_new_rounded, size: 14),
                label: Text(l10n.providerDetailViewOnMap,
                    style: theme.textTheme.labelSmall),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  const _MapGridPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 0.5;

    const step = 24.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_MapGridPainter old) => old.color != color;
}

// ─── Contact tile ─────────────────────────────────────────────────────────────

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.label,
    required this.ctx,
  });

  final IconData icon;
  final String label;
  final BuildContext ctx;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(ctx).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: scheme.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(label, style: Theme.of(ctx).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
