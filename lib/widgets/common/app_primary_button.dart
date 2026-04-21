import 'package:batchit/themes/app_icons.dart';
import 'package:batchit/themes/app_motion.dart';
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
    final onTap = isLoading ? null : onPressed;

    if (isSecondary) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onTap,
          child: _ButtonChild(label: label, isLoading: isLoading, icon: icon),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onTap,
        child: AnimatedSwitcher(
          duration: AppMotion.fast,
          switchInCurve: AppMotion.emphasized,
          switchOutCurve: Curves.easeIn,
          child: _ButtonChild(
            key: ValueKey<bool>(isLoading),
            label: label,
            isLoading: isLoading,
            icon: icon,
          ),
        ),
      ),
    );
  }
}

class _ButtonChild extends StatelessWidget {
  const _ButtonChild({
    super.key,
    required this.label,
    required this.isLoading,
    required this.icon,
  });

  final String label;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 18,
        width: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (icon == null) {
      return Text(label);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: AppIcons.md),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
