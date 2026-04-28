import 'package:flutter/material.dart';

Widget arsaHover({required Widget child}) {
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 12), // Mengatur jarak floating
    duration: const Duration(seconds: 2),
    curve: Curves.easeInOutSine,
    builder: (context, value, child) {
      return Transform.translate(offset: Offset(0, value), child: child);
    },
    child: child,
  );
}
