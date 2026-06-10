import 'package:flutter/material.dart';

import '../models/asteroid.dart';
import '../theme/cosmos_theme.dart';
import 'glass_panel.dart';

class AsteroidCard extends StatelessWidget {
  const AsteroidCard({
    super.key,
    required this.designation,
    required this.status,
    required this.velocity,
    required this.diameter,
    required this.missDistance,
    this.onTap,
  });

  final String designation;
  final AsteroidStatus status;
  final String velocity;
  final String diameter;
  final String missDistance;
  final VoidCallback? onTap;

  ({Color dot, Color text, Color border, Color fill, String label, bool glow})
  get _statusTokens {
    switch (status) {
      case AsteroidStatus.closeApproach:
        return (
          dot: CosmosColors.error,
          text: CosmosColors.error,
          border: CosmosColors.error.withValues(alpha: 0.3),
          fill: CosmosColors.error.withValues(alpha: 0.1),
          label: 'CLOSE APPROACH',
          glow: true,
        );
      case AsteroidStatus.monitoring:
        return (
          dot: CosmosColors.secondary,
          text: CosmosColors.secondary,
          border: CosmosColors.secondary.withValues(alpha: 0.3),
          fill: CosmosColors.secondary.withValues(alpha: 0.1),
          label: 'MONITORING',
          glow: true,
        );
      case AsteroidStatus.nominal:
        return (
          dot: CosmosColors.outline,
          text: CosmosColors.onSurfaceVariant,
          border: CosmosColors.outline.withValues(alpha: 0.3),
          fill: CosmosColors.surfaceContainerLow,
          label: 'NOMINAL',
          glow: false,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = _statusTokens;
    return GestureDetector(
      onTap: onTap,
      child: GlassPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DESIGNATION',
                        style: CosmosTextStyles.labelCaps(
                          color: CosmosColors.onSurfaceVariant,
                          letterSpacing: 1.6,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(designation, style: CosmosTextStyles.headlineMd()),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _StatusPill(
                  label: tokens.label,
                  dotColor: tokens.dot,
                  textColor: tokens.text,
                  borderColor: tokens.border,
                  fillColor: tokens.fill,
                  glow: tokens.glow,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _Stat(
                    icon: Icons.speed_outlined,
                    label: 'VELOCITY',
                    value: velocity,
                    valueColor: CosmosColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _Stat(
                    icon: Icons.open_in_full,
                    label: 'EST. DIA.',
                    value: diameter,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.only(top: 16),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: CosmosColors.hairline, width: 1),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Miss Distance: ',
                            style: CosmosTextStyles.bodySm(
                              color: CosmosColors.onSurfaceVariant,
                            ),
                          ),
                          TextSpan(
                            text: missDistance,
                            style: CosmosTextStyles.dataMono(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'TRAJECTORY',
                        style: CosmosTextStyles.labelCaps(
                          color: CosmosColors.primary,
                          letterSpacing: 1.4,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.chevron_right,
                        color: CosmosColors.primary,
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12),
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: CosmosColors.hairline, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: CosmosColors.onSurfaceVariant),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: CosmosTextStyles.labelCaps(
                    color: CosmosColors.onSurfaceVariant,
                    letterSpacing: 1.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: CosmosTextStyles.dataMono(color: valueColor)),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.dotColor,
    required this.textColor,
    required this.borderColor,
    required this.fillColor,
    required this.glow,
  });

  final String label;
  final Color dotColor;
  final Color textColor;
  final Color borderColor;
  final Color fillColor;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              boxShadow: glow
                  ? [
                      BoxShadow(
                        color: dotColor.withValues(alpha: 0.8),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: CosmosTextStyles.labelCaps(
              color: textColor,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
