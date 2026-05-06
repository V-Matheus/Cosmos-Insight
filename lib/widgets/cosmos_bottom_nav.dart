import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/cosmos_theme.dart';

class CosmosBottomNav extends StatelessWidget {
  const CosmosBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            border: const Border(
              top: BorderSide(color: CosmosColors.hairline, width: 1),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x80000000),
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  _NavItem(icon: Icons.today_outlined, label: 'TODAY'),
                  _NavItem(
                    icon: Icons.blur_on,
                    label: 'ASTEROIDS',
                    active: true,
                  ),
                  _NavItem(
                      icon: Icons.satellite_alt_outlined, label: 'ISS'),
                  _NavItem(
                      icon: Icons.photo_library_outlined, label: 'GALLERY'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active
        ? CosmosColors.primaryContainer
        : const Color(0xFF748191).withValues(alpha: 0.6);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (active)
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: CosmosColors.primaryContainer,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color:
                      CosmosColors.primaryContainer.withValues(alpha: 0.6),
                  blurRadius: 10,
                ),
              ],
            ),
          )
        else
          const SizedBox(height: 8),
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
