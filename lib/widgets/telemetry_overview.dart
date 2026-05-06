import 'package:flutter/material.dart';

import '../theme/cosmos_theme.dart';
import 'glass_panel.dart';

class TelemetryOverview extends StatelessWidget {
  const TelemetryOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: CosmosColors.primaryContainer,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: CosmosColors.primaryContainer
                          .withValues(alpha: 0.8),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'GLOBAL SCAN ACTIVE',
                style: CosmosTextStyles.labelCaps(
                  color: CosmosColors.primary,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: 'TRACKED OBJECTS',
                  value: '1,204',
                  valueColor: CosmosColors.onSurface,
                ),
              ),
              Expanded(
                child: _Metric(
                  label: 'CLOSEST APPROACH',
                  value: '0.02 AU',
                  valueColor: CosmosColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: CosmosTextStyles.labelCaps(
            color: CosmosColors.onSurfaceVariant,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: CosmosTextStyles.dataMono(color: valueColor)
              .copyWith(fontSize: 20),
        ),
      ],
    );
  }
}
