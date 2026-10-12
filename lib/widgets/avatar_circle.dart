import 'package:flutter/material.dart';

/// A reusable avatar circle with initials and gradient background.
class AvatarCircle extends StatelessWidget {
  const AvatarCircle({
    super.key,
    required this.initials,
    this.radius = 48,
    this.gradient,
  });

  final String initials;
  final double radius;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gradient ??
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cs.primary,
                cs.tertiary,
              ],
            ),
      ),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: TextStyle(
            fontSize: radius * 0.55,
            fontWeight: FontWeight.w700,
            color: cs.onPrimary,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
