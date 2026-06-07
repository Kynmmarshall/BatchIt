import 'package:flutter/material.dart';

/// Horizontal distance filter bar with a draggable slider and "Within X km" label.
/// Use [onChanged] for live label updates and [onChangeEnd] to trigger expensive
/// operations (API calls, heavy filtering) only when the user releases the thumb.
class DistanceFilterBar extends StatelessWidget {
  const DistanceFilterBar({
    super.key,
    required this.value,
    required this.onChanged,
    this.onChangeEnd,
    this.min = 1.0,
    this.max = 100.0,
    this.hasLocation = true,
  });

  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeEnd;
  final bool hasLocation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(
            Icons.near_me_rounded,
            size: 18,
            color: hasLocation ? scheme.primary : scheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Flexible(
            fit: FlexFit.loose,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Within ${value.round()} km',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (!hasLocation)
                  Text(
                    'Enable location for best results',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                activeTrackColor: scheme.primary,
                inactiveTrackColor: scheme.outlineVariant,
                thumbColor: scheme.primary,
                overlayColor: scheme.primary.withValues(alpha: 0.15),
              ),
              child: Slider(
                value: value.clamp(min, max),
                min: min,
                max: max,
                onChanged: onChanged,
                onChangeEnd: onChangeEnd,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
