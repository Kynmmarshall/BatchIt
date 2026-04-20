String formatKg(double value) {
  if (value == value.roundToDouble()) {
    return '${value.toInt()}kg';
  }
  return '${value.toStringAsFixed(1)}kg';
}
