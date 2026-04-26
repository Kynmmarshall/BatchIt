import 'package:flutter/material.dart';

typedef AuthBodyBuilder =
    Widget Function(BuildContext context, BoxConstraints constraints);

class AuthScreenShell extends StatelessWidget {
  const AuthScreenShell({
    super.key,
    required this.childBuilder,
    this.padding = const EdgeInsets.fromLTRB(24, 20, 24, 26),
  });

  final AuthBodyBuilder childBuilder;
  final EdgeInsetsGeometry padding;

  static const Color pageBackground = Color(0xFFEDEDED);
  static const double maxWidth = 414;
  static const double panelRadius = 32;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/background/background.png', fit: BoxFit.cover),
            Container(color: Colors.white.withValues(alpha: 0.26)),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: maxWidth),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.58),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(panelRadius),
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
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
          ],
        ),
      ),
    );
  }
}
