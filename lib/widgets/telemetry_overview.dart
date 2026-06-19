import 'package:flutter/material.dart';

import '../theme/cosmos_theme.dart';
import 'glass_panel.dart';

class TelemetryOverview extends StatelessWidget {
  const TelemetryOverview({
    super.key,
    this.trackedObjects = '—',
    this.closestApproach = '—',
  });

  /// Number of objects currently loaded in the catalogue.
  final String trackedObjects;

  /// Closest approach across the loaded catalogue (e.g. '0.00021 AU').
  final String closestApproach;

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
                      color: CosmosColors.primaryContainer.withValues(
                        alpha: 0.8,
                      ),
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
                  value: trackedObjects,
                  valueColor: CosmosColors.onSurface,
                ),
              ),
              Expanded(
                child: _Metric(
                  label: 'CLOSEST APPROACH',
                  value: closestApproach,
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
          style: CosmosTextStyles.dataMono(
            color: valueColor,
          ).copyWith(fontSize: 20),
        ),
      ],
    );
  }
}
