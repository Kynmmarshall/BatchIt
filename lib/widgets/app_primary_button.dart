import 'package:batchit/themes/app_icons.dart';
import 'package:flutter/material.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isSecondary = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool isSecondary;

  @override
  Widget build(BuildContext context) {
    final effectiveCallback = isLoading ? null : onPressed;
    final content = _content();

    final button = isSecondary
        ? OutlinedButton(onPressed: effectiveCallback, child: content)
        : FilledButton(onPressed: effectiveCallback, child: content);

    // Row + Expanded gives the button tight finite width — cannot produce
    // BoxConstraints(w=Infinity) because LayoutBuilder guarantees bounded parent.
    return LayoutBuilder(
      builder: (_, constraints) => constraints.hasBoundedWidth
          ? Row(children: [Expanded(child: button)])
          : button,
    );
  }

  Widget _content() {
    if (isLoading) {
      return const SizedBox(
        height: 18,
        width: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    if (icon == null) return Text(label);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: AppIcons.md),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
