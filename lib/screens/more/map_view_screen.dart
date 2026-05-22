import 'package:batchit/core/app_routes.dart';
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/models/provider_profile.dart';
import 'package:batchit/services/provider_service.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:url_launcher/url_launcher.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key, this.focusedProviderId});

  final String? focusedProviderId;

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  final _service = ProviderService();
  final _mapController = MapController();

  List<ProviderProfile> _providers = [];
  bool _loading = true;
  String? _highlightedId;

  static const _defaultCenter = LatLng(33.5731, -7.5898);
  static const _defaultZoom = 12.0;
  static const _focusedZoom = 15.5;

  @override
  void initState() {
    super.initState();
    _highlightedId = widget.focusedProviderId;
    _load();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final providers = await _service.fetchAllProviders();
    if (!mounted) return;
    setState(() {
      _providers = providers;
      _loading = false;
    });

    if (widget.focusedProviderId != null) {
      try {
        final focused =
            providers.firstWhere((p) => p.id == widget.focusedProviderId);
        if (focused.latitude != null && focused.longitude != null) {
          _mapController.move(
            LatLng(focused.latitude!, focused.longitude!),
            _focusedZoom,
          );
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _showSheet(focused);
          });
        }
      } catch (_) {}
    }
  }

  void _showSheet(ProviderProfile provider) {
    setState(() => _highlightedId = provider.id);
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _ProviderSheet(
        provider: provider,
        onViewDetails: () {
          Navigator.of(ctx).pop();
          Navigator.pushNamed(context, AppRoutes.providerDetail,
              arguments: provider.id);
        },
        onGetDirections: () => _openMaps(provider),
      ),
    ).whenComplete(() {
      if (mounted) setState(() => _highlightedId = null);
    });
  }

  Future<void> _openMaps(ProviderProfile p) async {
    final lat = p.latitude;
    final lng = p.longitude;
    if (lat == null || lng == null) return;

    final encoded = Uri.encodeComponent(p.businessName);
    final googleUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng&query=$encoded');
    final geoUrl = Uri.parse('geo:$lat,$lng?q=$lat,$lng($encoded)');

    if (await canLaunchUrl(googleUrl)) {
      await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(geoUrl)) {
      await launchUrl(geoUrl, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.mapOpenError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final withCoords = _providers.where((p) => p.latitude != null).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.mapViewTitle),
        actions: [
          if (!_loading && withCoords > 0)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: Chip(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.storefront_rounded,
                        size: 14, color: scheme.onPrimaryContainer),
                    const SizedBox(width: 4),
                    Text(
                      '$withCoords',
                      style: TextStyle(
                          color: scheme.onPrimaryContainer, fontSize: 12),
                    ),
                  ],
                ),
                backgroundColor: scheme.primaryContainer,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                initialCenter: _defaultCenter,
                initialZoom: _defaultZoom,
                minZoom: 4,
                maxZoom: 18,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'app.batchit',
                ),
                MarkerLayer(
                  markers: _providers
                      .where((p) => p.latitude != null && p.longitude != null)
                      .map((p) {
                    final focused = p.id == _highlightedId;
                    return Marker(
                      point: LatLng(p.latitude!, p.longitude!),
                      width: focused ? 60 : 48,
                      height: focused ? 76 : 62,
                      alignment: Alignment.bottomCenter,
                      child: GestureDetector(
                        onTap: () => _showSheet(p),
                        child: _ProviderPin(
                          provider: p,
                          focused: focused,
                          scheme: scheme,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }
}

// ── Pin marker ────────────────────────────────────────────────────────────────

class _ProviderPin extends StatelessWidget {
  const _ProviderPin({
    required this.provider,
    required this.focused,
    required this.scheme,
  });

  final ProviderProfile provider;
  final bool focused;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final color = focused ? scheme.error : scheme.primary;
    final circleSize = focused ? 56.0 : 44.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.storefront_rounded,
            color: Colors.white,
            size: focused ? 28 : 22,
          ),
        ),
        ClipPath(
          clipper: _TriangleClipper(),
          child: Container(
            width: focused ? 16 : 13,
            height: focused ? 14 : 11,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => Path()
    ..moveTo(0, 0)
    ..lineTo(size.width, 0)
    ..lineTo(size.width / 2, size.height)
    ..close();

  @override
  bool shouldReclip(_TriangleClipper old) => false;
}

// ── Bottom sheet ──────────────────────────────────────────────────────────────

class _ProviderSheet extends StatelessWidget {
  const _ProviderSheet({
    required this.provider,
    required this.onViewDetails,
    required this.onGetDirections,
  });

  final ProviderProfile provider;
  final VoidCallback onViewDetails;
  final VoidCallback onGetDirections;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                _Avatar(provider: provider, scheme: scheme),
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
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (provider.isVerified) ...[
                            const SizedBox(width: 4),
                            Icon(Icons.verified_rounded,
                                size: 16, color: scheme.primary),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.place_rounded,
                              size: 12, color: scheme.onSurfaceVariant),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              provider.address,
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                    ),
                    onPressed: onGetDirections,
                    icon: const Icon(Icons.directions_rounded, size: 18),
                    label: Text(l10n.getDirections),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 44),
                    ),
                    onPressed: onViewDetails,
                    icon: const Icon(Icons.storefront_rounded, size: 18),
                    label: Text(l10n.viewDetails),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.provider, required this.scheme});

  final ProviderProfile provider;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final hasLogo =
        provider.logoUrl != null && provider.logoUrl!.isNotEmpty;
    return CircleAvatar(
      radius: 26,
      backgroundColor: scheme.primaryContainer,
      backgroundImage: hasLogo ? NetworkImage(provider.logoUrl!) : null,
      child: hasLogo
          ? null
          : Text(
              provider.businessName.isNotEmpty
                  ? provider.businessName[0].toUpperCase()
                  : '?',
              style: TextStyle(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
    );
  }
}
