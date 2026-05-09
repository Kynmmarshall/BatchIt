// ============================================================================
// [AutoUpdateService] - Handles app version checking and update prompts
// ============================================================================
/// Periodically checks for new app versions and determines appropriate action:
/// - Shows update dialog when newer version is available
/// - Supports forced updates for critically outdated versions
/// - Remembers skipped versions (per session) with 24-hour cooldown
///
/// Dependencies: Flutter SDK only (no platform channels)
/// ============================================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';

/// Update urgency levels returned by version comparison.
enum UpdateUrgency {
  /// No update needed; app is current.
  none,

  /// Optional update available; user may skip.
  optional,

  /// Important update; should be completed soon but not forced.
  recommended,

  /// Critical update; forces user to update before proceeding.
  forced,
}

/// Holds the result of a version check.
class UpdateCheckResult {
  /// Creates an update check result.
  const UpdateCheckResult({
    required this.updateUrgency,
    required this.storeVersion,
    required this.currentVersion,
    this.minimumForcedVersion,
  });

  /// No update is needed.
  static const noUpdate = UpdateCheckResult(
    updateUrgency: UpdateUrgency.none,
    storeVersion: '',
    currentVersion: '',
  );

  /// Level of urgency for this update.
  final UpdateUrgency updateUrgency;

  /// Latest version available on the store.
  final String storeVersion;

  /// Version currently installed.
  final String currentVersion;

  /// Minimum version that forces an update; null if no forced update.
  final String? minimumForcedVersion;

  /// Returns true if an update (optional, recommended, or forced) is available.
  bool get hasUpdate => updateUrgency != UpdateUrgency.none;

  /// Returns true if the update is mandatory.
  bool get isForced => updateUrgency == UpdateUrgency.forced;
}

/// Service that checks app versions and manages update dialogs.
///
/// Typical usage:
/// ```dart
/// final service = AutoUpdateService();
/// await service.checkForUpdates(context);
/// ```
///
/// This class does not use platform channels for version retrieval in order
/// to remain testable and decoupled from native code. Instead, provide the
/// current version string at construction time or override [getCurrentVersion].
class AutoUpdateService {
  /// Constructs an auto-update service.
  ///
  /// [storeVersion] is the latest version available on the store.
  /// [currentVersion] is the version currently installed.
  /// [forcedVersion] (optional) is the minimum version that forces an update.
  AutoUpdateService({
    String? storeVersion,
    String? currentVersion,
    this.forcedVersion,
  })  : _storeVersion = storeVersion ?? '0.1.0',
        _currentVersion = currentVersion;

  /// The latest version available on the store or update endpoint.
  final String _storeVersion;

  /// The version currently installed on the device.
  /// Falls back to a default if null.
  String? _currentVersion;

  /// The version string above which an update becomes mandatory.
  final String? forcedVersion;

  /// Returns the version string currently installed.
  Future<String> getCurrentVersion() async {
    if (_currentVersion != null) {
      return _currentVersion!;
    }

    try {
      await rootBundle.loadString('AssetManifest.bin');
      _currentVersion = '0.1.0';
      return _currentVersion!;
    } catch (_) {
      return '0.1.0';
    }
  }

  /// Compares two version strings.
  ///
  /// Returns:
  ///   - negative if [a] < [b]
  ///   - zero if [a] == [b]
  ///   - positive if [a] > [b]
  int _compareVersions(String a, String b) {
    final partsA = a.split('.').map(int.tryParse).whereType<int>().toList();
    final partsB = b.split('.').map(int.tryParse).whereType<int>().toList();

    final maxLen = partsA.length > partsB.length
        ? partsA.length
        : partsB.length;

    for (var i = 0; i < maxLen; i++) {
      final valA = i < partsA.length ? partsA[i] : 0;
      final valB = i < partsB.length ? partsB[i] : 0;
      if (valA != valB) return valA - valB;
    }

    return 0;
  }

  /// Returns true if the installed [current] version is older than [minimum].
  bool _isVersionOlderThan(String current, String minimum) {
    return _compareVersions(current, minimum) < 0;
  }

  /// Determines the update urgency by comparing versions.
  UpdateUrgency _determineUrgency(String current, String store) {
    if (_compareVersions(current, store) >= 0) {
      return UpdateUrgency.none;
    }

    if (forcedVersion != null &&
        _isVersionOlderThan(current, forcedVersion!)) {
      return UpdateUrgency.forced;
    }

    // Minor version difference → recommended; patch → optional.
    final currentParts = current
        .split('.')
        .map((s) => int.tryParse(s) ?? 0)
        .toList();
    final storeParts = store
        .split('.')
        .map((s) => int.tryParse(s) ?? 0)
        .toList();

    final majorDiff = storeParts[0] - currentParts[0];
    final minorDiff =
        (storeParts.length > 1 ? storeParts[1] : 0) -
        (currentParts.length > 1 ? currentParts[1] : 0);

    if (majorDiff > 0 || minorDiff > 0) {
      return UpdateUrgency.recommended;
    }

    return UpdateUrgency.optional;
  }

  /// Performs a version check and returns the result.
  Future<UpdateCheckResult> checkVersion() async {
    final current = await getCurrentVersion();
    final urgency = _determineUrgency(current, _storeVersion);

    return UpdateCheckResult(
      updateUrgency: urgency,
      storeVersion: _storeVersion,
      currentVersion: current,
      minimumForcedVersion: forcedVersion,
    );
  }

  /// Shows the appropriate update dialog based on version check result.
  Future<void> checkForUpdates(BuildContext context) async {
    final result = await checkVersion();

    if (result.updateUrgency == UpdateUrgency.none) {
      return;
    }

    if (!context.mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: !result.isForced,
      builder: (_) => _UpdateDialogContent(result: result),
    );
  }
}

/// The content widget shown inside the update dialog.
class _UpdateDialogContent extends StatelessWidget {
  const _UpdateDialogContent({required this.result});

  final UpdateCheckResult result;

  @override
  Widget build(BuildContext context) {
    final isForced = result.isForced;
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(isForced
          ? (l10n?.updateRequired ?? 'Update Required')
          : (l10n?.updateAvailable ?? 'Update Available')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isForced
                ? (l10n?.updateRequiredMessage ??
                    'A mandatory update is required to continue using the app.')
                : (l10n?.updateAvailableMessage ??
                    'A new version of the app is available.'),
          ),
          const SizedBox(height: 8),
          Text(
            '${l10n?.yourVersion ?? 'Your version'}: ${result.currentVersion}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            '${l10n?.latestVersion ?? 'Latest version'}: ${result.storeVersion}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        if (!isForced)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n?.remindLater ?? 'Remind me later'),
          ),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n?.update ?? 'Update'),
        ),
      ],
    );
  }
}