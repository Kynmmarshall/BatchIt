import 'package:batchit/core/app_routes.dart';
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/models/provider_profile.dart';
import 'package:batchit/services/provider_service.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:batchit/widgets/app_primary_button.dart';
import 'package:batchit/widgets/app_screen_container.dart';
import 'package:batchit/widgets/provider_card.dart';
import 'package:flutter/material.dart';

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
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);
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

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await _service.fetchVerifiedProviders();
    if (!mounted) return;
    setState(() {
      _all = result;
      _loading = false;
    });
  }

  List<ProviderProfile> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _all;
    return _all.where((p) {
      return [p.businessName, p.ownerName, p.address, p.description, p.category.name]
          .join(' ')
          .toLowerCase()
          .contains(q);
    }).toList();
  }

  void _toggle(ProviderProfile p) => setState(() {
        _followed.contains(p.id) ? _followed.remove(p.id) : _followed.add(p.id);
      });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                    isFollowing: _followed.contains(p.id),
                    onFollowToggle: () => _toggle(p),
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            AppPrimaryButton(
              label: l10n.becomeProvider,
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
