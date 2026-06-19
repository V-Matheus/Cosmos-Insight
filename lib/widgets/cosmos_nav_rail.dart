import 'package:flutter/material.dart';

import '../theme/cosmos_theme.dart';
import 'cosmos_bottom_nav.dart';

/// Desktop/tablet counterpart of [CosmosBottomNav]: a vertical navigation rail
/// pinned to the side of the shell. It consumes the SAME [kCosmosNavItems] and
/// the same `activeIndex`/`onTap` contract, so swapping between the two is a
/// pure layout decision (see `ResponsiveLayout`).
class CosmosNavRail extends StatelessWidget {
  const CosmosNavRail({
    super.key,
    required this.activeIndex,
    required this.onTap,
  });

  final int activeIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: CosmosColors.hairline, width: 1),
        ),
      ),
      child: SafeArea(
        right: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              for (var i = 0; i < kCosmosNavItems.length; i++)
                _RailItem(
                  icon: kCosmosNavItems[i].icon,
                  label: kCosmosNavItems[i].label,
                  active: i == activeIndex,
                  onTap: () => onTap(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active
        ? CosmosColors.primaryContainer
        : const Color(0xFF748191).withValues(alpha: 0.6);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: active
                ? CosmosColors.primaryContainer.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
