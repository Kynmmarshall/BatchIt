import 'package:batchit/core/app_routes.dart';
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/models/provider_profile.dart';
import 'package:batchit/services/provider_service.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
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
  final _distance = const Distance();

  List<ProviderProfile> _providers = [];
  bool _loading = true;
  bool _loadingLocation = false;
  bool _mapReady = false;
  bool _didFocusProvider = false;
  String? _highlightedId;
  MapDisplayMode _displayMode = MapDisplayMode.global;
  Position? _currentPosition;

  static const _defaultCenter = LatLng(33.5731, -7.5898);
  static const _defaultZoom = 12.0;
  static const _focusedZoom = 15.5;
  static const _nearbyRadiusKm = 12.0;

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

    _maybeFocusSelectedProvider();
  }

  void _onMapReady() {
    _mapReady = true;
    _maybeFocusSelectedProvider();
  }

  void _maybeFocusSelectedProvider() {
    if (!_mapReady || _didFocusProvider || widget.focusedProviderId == null) {
      return;
    }

    ProviderProfile? focused;
    try {
      focused = _providers.firstWhere((p) => p.id == widget.focusedProviderId);
    } catch (_) {
      focused = null;
    }
    if (focused == null || focused.latitude == null || focused.longitude == null) {
      return;
    }

    _didFocusProvider = true;
    final focusedProvider = focused;
    final target = LatLng(focusedProvider.latitude!, focusedProvider.longitude!);
    _mapController.move(target, _focusedZoom);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _showSheet(focusedProvider);
    });
  }

  List<ProviderProfile> get _visibleProviders {
    final providers = _providers
        .where((provider) => provider.latitude != null && provider.longitude != null)
        .toList();

    if (_displayMode == MapDisplayMode.global || _currentPosition == null) {
      return providers;
    }

    final current = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    return providers.where((provider) {
      final providerPoint = LatLng(provider.latitude!, provider.longitude!);
      final distanceKm = _distance.as(LengthUnit.Kilometer, current, providerPoint);
      return distanceKm <= _nearbyRadiusKm;
    }).toList();
  }

  Future<void> _centerOnCurrentLocation() async {
    setState(() => _loadingLocation = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied.');
      }

      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;

      setState(() {
        _currentPosition = position;
        _displayMode = MapDisplayMode.nearby;
      });
      _mapController.move(LatLng(position.latitude, position.longitude), 14.5);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.mapOpenError)),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  void _setDisplayMode(MapDisplayMode mode) {
    setState(() => _displayMode = mode);
  }

  void _showVisibleProvidersSheet() {
    final providers = _visibleProviders;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _displayMode == MapDisplayMode.nearby ? 'Nearby providers' : 'All providers',
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                providers.isEmpty
                    ? 'No providers found for the selected view.'
                    : '${providers.length} providers available',
                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (providers.isNotEmpty)
                SizedBox(
                  height: MediaQuery.of(ctx).size.height * 0.45,
                  child: ListView.separated(
                    itemCount: providers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      final provider = providers[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundImage: provider.logoUrl != null && provider.logoUrl!.isNotEmpty
                              ? NetworkImage(provider.logoUrl!)
                              : null,
                          child: provider.logoUrl == null || provider.logoUrl!.isEmpty
                              ? const Icon(Icons.storefront_rounded)
                              : null,
                        ),
                        title: Text(provider.businessName),
                        subtitle: Text(provider.address),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          Navigator.of(ctx).pop();
                          Navigator.pushNamed(
                            context,
                            AppRoutes.providerDetail,
                            arguments: provider.id,
                          );
                        },
                      );
                    },
                  ),
                ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
    final visibleProviders = _visibleProviders;
    final nearbyCount = _currentPosition == null
        ? 0
        : _providers.where((provider) {
            if (provider.latitude == null || provider.longitude == null) {
              return false;
            }
            final distanceKm = _distance.as(
              LengthUnit.Kilometer,
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
              LatLng(provider.latitude!, provider.longitude!),
            );
            return distanceKm <= _nearbyRadiusKm;
          }).length;

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
          IconButton(
            tooltip: 'Visible providers',
            onPressed: visibleProviders.isEmpty ? null : _showVisibleProvidersSheet,
            icon: const Icon(Icons.view_list_rounded),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _defaultCenter,
                    initialZoom: _defaultZoom,
                    minZoom: 4,
                    maxZoom: 18,
                    onMapReady: _onMapReady,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'app.batchit',
                    ),
                    MarkerLayer(
                      markers: [
                        ...visibleProviders.map((p) {
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
                        }),
                        if (_currentPosition != null)
                          Marker(
                            point: LatLng(
                              _currentPosition!.latitude,
                              _currentPosition!.longitude,
                            ),
                            width: 44,
                            height: 44,
                            child: Container(
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.my_location_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  top: AppSpacing.md,
                  child: Card(
                    elevation: 6,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _displayMode == MapDisplayMode.nearby
                                      ? 'Nearby providers'
                                      : 'Global providers',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _loadingLocation ? null : _centerOnCurrentLocation,
                                icon: _loadingLocation
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.my_location_rounded, size: 18),
                                label: const Text('My location'),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.xs,
                            children: [
                              ChoiceChip(
                                label: const Text('Global'),
                                selected: _displayMode == MapDisplayMode.global,
                                onSelected: (_) => _setDisplayMode(MapDisplayMode.global),
                              ),
                              ChoiceChip(
                                label: Text('Nearby${_currentPosition != null ? ' ($nearbyCount)' : ''}'),
                                selected: _displayMode == MapDisplayMode.nearby,
                                onSelected: (_) => _setDisplayMode(MapDisplayMode.nearby),
                              ),
                              Chip(label: Text('$withCoords mapped')),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            _displayMode == MapDisplayMode.nearby && _currentPosition != null
                                ? 'Showing providers within ${_nearbyRadiusKm.toStringAsFixed(0)} km of your location.'
                                : 'Showing all providers with map coordinates.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_displayMode == MapDisplayMode.nearby && _currentPosition == null)
                  Positioned(
                    left: AppSpacing.md,
                    right: AppSpacing.md,
                    bottom: AppSpacing.md,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Enable location to show nearby providers.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            FilledButton(
                              onPressed: _loadingLocation ? null : _centerOnCurrentLocation,
                              child: const Text('Enable'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

enum MapDisplayMode { global, nearby }

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
