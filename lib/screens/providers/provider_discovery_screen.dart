import 'package:batchit/core/app_routes.dart';
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/models/provider_profile.dart';
import 'package:batchit/providers/provider_provider.dart';
import 'package:batchit/services/provider_service.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:batchit/widgets/app_primary_button.dart';
import 'package:batchit/widgets/app_screen_container.dart';
import 'package:batchit/widgets/distance_filter_bar.dart';
import 'package:batchit/widgets/provider_card.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class ProviderDiscoveryScreen extends StatefulWidget {
  const ProviderDiscoveryScreen({super.key});

  @override
  State<ProviderDiscoveryScreen> createState() =>
      _ProviderDiscoveryScreenState();
}

class _ProviderDiscoveryScreenState extends State<ProviderDiscoveryScreen> {
  final _service = ProviderService();
  final _searchController = TextEditingController();
  final _followed = <String>{};

  List<ProviderProfile> _all = [];
  bool _loading = true;
  Position? _currentPosition;
  String _query = '';
  double _distanceKm = 20.0;
  bool _distanceFilterEnabled = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);
    _loadCurrentLocation();
    _load();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearch)
      ..dispose();
    super.dispose();
  }

  void _onSearch() => setState(() => _query = _searchController.text);

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

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      _service.fetchVerifiedProviders(),
      _service.fetchFollowedProviders(),
    ]);
    if (!mounted) return;
    final all = results[0];
    final followed = results[1];
    setState(() {
      _all = all;
      _followed
        ..clear()
        ..addAll(followed.map((p) => p.id));
      _loading = false;
    });
  }

  List<ProviderProfile> get _filtered {
    var results = _all;

    // Text search
    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      results = results.where((p) {
        return [p.businessName, p.ownerName, p.address, p.description, p.category.name]
            .join(' ')
            .toLowerCase()
            .contains(q);
      }).toList();
    }

    // Distance filter — only applied when enabled and we have the user's position.
    // Providers with no coordinates are kept so they are never silently hidden.
    final pos = _currentPosition;
    if (_distanceFilterEnabled && pos != null) {
      results = results.where((p) {
        final lat = p.latitude;
        final lng = p.longitude;
        if (lat == null || lng == null) return true;
        final meters = Geolocator.distanceBetween(
          pos.latitude, pos.longitude, lat, lng,
        );
        return meters <= _distanceKm * 1000;
      }).toList();
    }

    return results;
  }

  Future<void> _toggle(ProviderProfile p) async {
    final isFollowing = _followed.contains(p.id);
    // Optimistic update
    setState(() {
      isFollowing ? _followed.remove(p.id) : _followed.add(p.id);
    });
    try {
      if (isFollowing) {
        await _service.unfollowProvider(p.id);
      } else {
        await _service.followProvider(p.id);
      }
    } catch (_) {
      // Revert on failure
      if (mounted) {
        setState(() {
          isFollowing ? _followed.add(p.id) : _followed.remove(p.id);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final myProfile = context.watch<ProviderProvider>().myProfile;
    final providers = _filtered;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.providerDiscovery)),
      body: AppScreenContainer(
        child: ListView(
          children: [
            Text(
              l10n.providerDiscoverySubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(
                  _distanceFilterEnabled
                      ? Icons.near_me_rounded
                      : Icons.near_me_disabled,
                  size: 15,
                  color: _distanceFilterEnabled
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  'Distance filter',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: _distanceFilterEnabled
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(
                    () => _distanceFilterEnabled = !_distanceFilterEnabled,
                  ),
                  child: Icon(
                    _distanceFilterEnabled
                        ? Icons.toggle_on_rounded
                        : Icons.toggle_off_rounded,
                    size: 32,
                    color: _distanceFilterEnabled
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            if (_distanceFilterEnabled) ...[
              const SizedBox(height: 8),
              DistanceFilterBar(
                value: _distanceKm,
                hasLocation: _currentPosition != null,
                onChanged: (v) => setState(() => _distanceKm = v),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (providers.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(l10n.noSearchResults),
                ),
              )
            else
              ...providers.map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: ProviderCard(
                    provider: p,
                    currentPosition: _currentPosition,
                    isFollowing: _followed.contains(p.id),
                    onFollowToggle: () => _toggle(p).ignore(),
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            AppPrimaryButton(
              label: myProfile == null ? l10n.becomeProvider : 'My Provider Profile',
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.becomeProvider),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
