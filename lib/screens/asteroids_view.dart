import 'package:flutter/material.dart';

import '../theme/cosmos_theme.dart';
import '../widgets/asteroid_card.dart';
import '../widgets/telemetry_overview.dart';

class AsteroidsView extends StatelessWidget {
  const AsteroidsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      children: [
        Text('Near-Earth Objects', style: CosmosTextStyles.displayLg()),
        const SizedBox(height: 12),
        Text(
          "Real-time telemetry and tracking data for high-velocity "
          "celestial bodies in proximity to Earth's orbit. Data sourced "
          "from global observatory networks.",
          style: CosmosTextStyles.bodyMd(
            color: CosmosColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 32),
        const TelemetryOverview(),
        const SizedBox(height: 40),
        const AsteroidCard(
          designation: '99942 Apophis',
          status: AsteroidStatus.closeApproach,
          velocity: '30.73 km/s',
          diameter: '370 m',
          missDistance: '0.00021 AU',
        ),
        const SizedBox(height: 16),
        const AsteroidCard(
          designation: '101955 Bennu',
          status: AsteroidStatus.monitoring,
          velocity: '27.88 km/s',
          diameter: '490 m',
          missDistance: '0.05210 AU',
        ),
        const SizedBox(height: 16),
        const AsteroidCard(
          designation: '2023 DZ2',
          status: AsteroidStatus.nominal,
          velocity: '15.42 km/s',
          diameter: '60 m',
          missDistance: '0.10400 AU',
        ),
        const SizedBox(height: 16),
        const AsteroidCard(
          designation: '3122 Florence',
          status: AsteroidStatus.nominal,
          velocity: '13.53 km/s',
          diameter: '4.4 km',
          missDistance: '0.04723 AU',
        ),
      ],
    );
  }
}
