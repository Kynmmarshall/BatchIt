import 'package:batchit/themes/app_motion.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:batchit/themes/app_theme.dart';
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
    final background = Theme.of(context).extension<AppBackgroundTheme>();
    final imageAsset = background?.imageAsset ??
        (brightness == Brightness.dark
            ? 'assets/background/dark.png'
            : 'assets/background/light.png');

    return AnimatedContainer(
      duration: AppMotion.slow,
      curve: AppMotion.emphasized,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imageAsset),
          fit: BoxFit.cover,
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
