import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sakupintar/core/constants/app_animation.dart';

class ArsaCharacter extends StatelessWidget {
  final bool isHappy; // Contoh state untuk interaksi interaktif

  const ArsaCharacter({super.key, this.isHappy = true});

  @override
  Widget build(BuildContext context) {
    return arsaHover(
      child: Lottie.asset(
        'assets/animations/arsa_robot.json',
        width: 180,
        height: 180,
        animate: true,
        repeat: true,
      ),
    );
  }
}
