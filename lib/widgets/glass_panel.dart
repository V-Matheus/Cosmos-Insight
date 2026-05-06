import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/cosmos_theme.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.borderRadius = 8,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: CosmosColors.glassFill,
            borderRadius: radius,
            border: Border.all(color: CosmosColors.glassBorder, width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}
