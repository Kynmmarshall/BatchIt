import 'package:batchit/core/app_routes.dart';
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/models/provider_profile.dart';
import 'package:batchit/providers/provider_provider.dart';
import 'package:batchit/services/provider_service.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:batchit/widgets/app_primary_button.dart';
import 'package:batchit/widgets/app_screen_container.dart';
import 'package:batchit/widgets/provider_distance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Full-detail view for a single verified provider.
/// Receives the provider ID as a route argument (String).
class ProviderDetailScreen extends StatefulWidget {
  const ProviderDetailScreen({super.key, required this.providerId});

  final String providerId;

  @override
  State<ProviderDetailScreen> createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends State<ProviderDetailScreen> {
  final _providerService = ProviderService();
  bool _isFollowing = false;
  bool _isLoadingFollow = true;
  ProviderProfile? _provider;
  bool _isLoadingProvider = true;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _loadProvider();
    _loadFollowStatus();
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() => _currentPosition = position);
    } catch (_) {}
  }

  Future<void> _loadProvider() async {
    final stateProvider = context.read<ProviderProvider>().findById(widget.providerId);
    if (stateProvider != null) {
      if (!mounted) return;
      setState(() {
        _provider = stateProvider;
        _isLoadingProvider = false;
      });
      return;
    }

    try {
      final fetched = await _providerService.fetchProviderById(widget.providerId);
      if (!mounted) return;
      setState(() {
        _provider = fetched;
        _isLoadingProvider = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _provider = null;
        _isLoadingProvider = false;
      });
    }
  }

  Future<void> _loadFollowStatus() async {
    final followed = await _providerService.fetchFollowedProviders();
    if (!mounted) return;
    setState(() {
      _isFollowing = followed.any((p) => p.id == widget.providerId);
      _isLoadingFollow = false;
    });
  }

  Future<void> _toggleFollow() async {
    final wasFollowing = _isFollowing;
    setState(() => _isFollowing = !_isFollowing);
    try {
      if (wasFollowing) {
        await _providerService.unfollowProvider(widget.providerId);
      } else {
        await _providerService.followProvider(widget.providerId);
      }
    } catch (_) {
      if (mounted) setState(() => _isFollowing = wasFollowing);
    }
  }

  ProviderProfile? _resolve(ProviderProvider state) =>
      state.findById(widget.providerId);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = context.watch<ProviderProvider>();
    final provider = _provider ?? _resolve(state);

    if ((_isLoadingProvider || state.isLoading) && provider == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.providerDetailTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (provider == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.providerDetailTitle)),
        body: Center(child: Text(l10n.providerNotFound)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(provider.businessName),
      ),
      body: AppScreenContainer(
        child: ListView(
          children: [
            // ── Hero header ─────────────────────────────────────────────
            _HeroHeader(provider: provider),

            const SizedBox(height: AppSpacing.sm),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isLoadingFollow ? null : _toggleFollow,
                icon: _isLoadingFollow
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _isFollowing
                            ? Icons.notifications_active_rounded
                            : Icons.notifications_none_rounded,
                      ),
                label: Text(
                  _isFollowing ? l10n.providerCardFollowing : l10n.providerCardFollow,
                ),
              ),
            ),

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
                ProviderDistanceLine(
                  provider: provider,
                  currentPosition: _currentPosition,
                ),
                if (provider.latitude != null && provider.longitude != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  _CoordinatesRow(provider: provider, l10n: l10n),
                  const SizedBox(height: AppSpacing.sm),
                  _LiveMapView(provider: provider, l10n: l10n),
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

            if (provider.latitude != null && provider.longitude != null) ...[
              const SizedBox(height: AppSpacing.sm),
              AppPrimaryButton(
                label: l10n.getDirections,
                icon: Icons.directions_rounded,
                isSecondary: true,
                onPressed: () => _openMaps(
                  context,
                  provider.latitude!,
                  provider.longitude!,
                  provider.businessName,
                  l10n,
                ),
              ),
            ],

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

  Future<void> _openMaps(
    BuildContext context,
    double lat,
    double lng,
    String name,
    AppLocalizations l10n,
  ) async {
    final encoded = Uri.encodeComponent(name);
    final googleUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng&query=$encoded',
    );
    final geoUrl = Uri.parse('geo:$lat,$lng?q=$lat,$lng($encoded)');

    if (await canLaunchUrl(googleUrl)) {
      await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(geoUrl)) {
      await launchUrl(geoUrl, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.mapOpenError)),
      );
    }
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

// ─── Live map view (flutter_map + OpenStreetMap) ──────────────────────────────

class _LiveMapView extends StatelessWidget {
  const _LiveMapView({required this.provider, required this.l10n});

  final ProviderProfile provider;
  final AppLocalizations l10n;



  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final location = LatLng(provider.latitude!, provider.longitude!);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 200,
        width: double.infinity,
        child: Stack(
          children: [
            // ── Real OpenStreetMap tile layer ─────────────────────────────
            FlutterMap(
              options: MapOptions(
                initialCenter: location,
                initialZoom: 15,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'app.batchit',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: location,
                      width: 48,
                      height: 48,
                      child: Icon(
                        Icons.location_pin,
                        color: scheme.error,
                        size: 48,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // ── Provider name label ───────────────────────────────────────
            Positioned(
              top: AppSpacing.xs,
              left: AppSpacing.xs,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                decoration: BoxDecoration(
                  color: scheme.surface.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.storefront_rounded,
                        size: 12, color: scheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      provider.businessName,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── "View on Map" / open in native maps button ────────────────
            Positioned(
              bottom: AppSpacing.xs,
              right: AppSpacing.xs,
              child: FilledButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.mapView,
                  arguments: provider.id,
                ),
                style: FilledButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 6),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: theme.textTheme.labelSmall,
                ),
                icon: const Icon(Icons.map_rounded, size: 14),
                label: Text(l10n.providerDetailViewOnMap),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
