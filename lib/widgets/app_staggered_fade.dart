import 'package:batchit/themes/app_motion.dart';
import 'package:flutter/material.dart';

class AppStaggeredFade extends StatefulWidget {
  const AppStaggeredFade({
    super.key,
    required this.child,
    this.index = 0,
    this.beginOffset = const Offset(0, 0.04),
  });

  final Widget child;
  final int index;
  final Offset beginOffset;

  @override
  State<AppStaggeredFade> createState() => _AppStaggeredFadeState();
}

class _AppStaggeredFadeState extends State<AppStaggeredFade> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(AppMotion.stagger(widget.index), () {
        if (!mounted) {
          return;
        }
        setState(() {
          _visible = true;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: AppMotion.medium,
      curve: AppMotion.emphasized,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : widget.beginOffset,
        duration: AppMotion.medium,
        curve: AppMotion.emphasized,
        child: widget.child,
      ),
    );
  }
}
