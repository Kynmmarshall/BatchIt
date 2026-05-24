import 'package:batchit/models/provider_profile.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class ProviderDistanceLine extends StatelessWidget {
  const ProviderDistanceLine({
    super.key,
    required this.provider,
    required this.currentPosition,
    this.compact = false,
  });

  final ProviderProfile provider;
  final Position? currentPosition;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final latitude = provider.latitude;
    final longitude = provider.longitude;
    if (currentPosition == null || latitude == null || longitude == null) {
      return const SizedBox.shrink();
    }

    final meters = Geolocator.distanceBetween(
      currentPosition!.latitude,
      currentPosition!.longitude,
      latitude,
      longitude,
    );

    final distanceText = meters < 1000
        ? '${meters.round()} m away'
        : '${(meters / 1000).toStringAsFixed(1)} km away';

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
      child: Row(
        children: [
          Icon(
            Icons.place_rounded,
            size: compact ? 14 : 16,
            color: scheme.primary,
          ),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            distanceText,
            style: (compact
                    ? theme.textTheme.bodySmall
                    : theme.textTheme.bodyMedium)
                ?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}