import 'dart:ui';

import 'package:flutter/material.dart';

class Glass extends StatelessWidget {
  const Glass({
    Key key,
    this.color = Colors.transparent,
    this.blur = 5.0,
    this.opacity = 0.5,
    this.child,
  }) : super(key: key);
  final Color color;
  final double blur;
  final double opacity;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          child: child,
          color: color.withOpacity(opacity),
        ),
      ),
    );
  }
}
