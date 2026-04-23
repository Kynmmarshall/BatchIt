import 'package:batchit/themes/app_colors.dart';
import 'package:batchit/themes/app_motion.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:flutter/material.dart';

class AppScreenContainer extends StatelessWidget {
  const AppScreenContainer({
    super.key,
    required this.child,
    this.padding = AppSpacing.screenPadding,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return AnimatedContainer(
      duration: AppMotion.slow,
      curve: AppMotion.emphasized,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: brightness == Brightness.dark
              ? AppColors.darkPageGradient
              : AppColors.lightPageGradient,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
