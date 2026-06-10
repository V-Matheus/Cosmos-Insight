import 'package:flutter/material.dart';

import '../models/asteroid.dart';
import '../theme/cosmos_theme.dart';
import '../widgets/glass_panel.dart';

/// Requirement (4): this screen is built entirely from an [Asteroid] received
/// as the `arguments` of a named route ([AppRoutes.asteroidDetail]).
///
/// It is pushed onto the ASTEROIDS tab's nested navigator, so it sits above the
/// list in that tab's history while the BottomNavigationBar stays visible.
class AsteroidDetailScreen extends StatelessWidget {
  const AsteroidDetailScreen({super.key, required this.asteroid});

  final Asteroid asteroid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          _BackRow(
            label: 'NEAR-EARTH OBJECTS',
            onBack: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 16),
          Text(asteroid.designation, style: CosmosTextStyles.displayLg()),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: asteroid.status.dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                asteroid.status.label,
                style: CosmosTextStyles.labelCaps(
                  color: asteroid.status.dotColor,
                  letterSpacing: 1.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          GlassPanel(
            child: Column(
              children: [
                _DetailRow('VELOCITY', asteroid.velocity),
                const Divider(color: CosmosColors.hairline, height: 24),
                _DetailRow('EST. DIAMETER', asteroid.diameter),
                const Divider(color: CosmosColors.hairline, height: 24),
                _DetailRow('MISS DISTANCE', asteroid.missDistance),
                const Divider(color: CosmosColors.hairline, height: 24),
                _DetailRow('MAGNITUDE', asteroid.magnitude),
                const Divider(color: CosmosColors.hairline, height: 24),
                _DetailRow('FIRST OBSERVED', asteroid.firstObserved),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'BRIEFING',
            style: CosmosTextStyles.labelCaps(
              color: CosmosColors.onSurfaceVariant,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            asteroid.briefing,
            style: CosmosTextStyles.bodyMd(
              color: CosmosColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: CosmosTextStyles.labelCaps(
              color: CosmosColors.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Text(value, style: CosmosTextStyles.dataMono()),
      ],
    );
  }
}

/// Shared back affordance for screens pushed inside a tab navigator.
class _BackRow extends StatelessWidget {
  const _BackRow({required this.label, required this.onBack});
  final String label;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onBack,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            const Icon(
              Icons.arrow_back,
              color: CosmosColors.primaryContainer,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: CosmosTextStyles.labelCaps(
                color: CosmosColors.primaryContainer,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
