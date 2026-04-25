import 'package:flutter/material.dart';

typedef AuthBodyBuilder = Widget Function(
  BuildContext context,
  BoxConstraints constraints,
);

class AuthScreenShell extends StatelessWidget {
  const AuthScreenShell({
    super.key,
    required this.childBuilder,
    this.padding = const EdgeInsets.fromLTRB(24, 20, 24, 26),
  });

  final AuthBodyBuilder childBuilder;
  final EdgeInsetsGeometry padding;

  static const Color pageBackground = Color(0xFFEDEDED);
  static const Color panelBackground = Colors.white;
  static const double maxWidth = 414;
  static const double panelRadius = 32;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxWidth),
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: panelBackground,
                borderRadius: BorderRadius.all(Radius.circular(panelRadius)),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: padding,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: childBuilder(context, constraints),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}