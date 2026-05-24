/// Format a quantity value with its unit label (e.g. "25 kg", "500 mL").
String formatQty(double value, String unit) {
  final numStr = value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1);
  return '$numStr $unit';
}

/// Legacy helper that always appends 'kg'. Kept for backward compat.
String formatKg(double value) => formatQty(value, 'kg');
