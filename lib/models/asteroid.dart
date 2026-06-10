import 'package:flutter/material.dart';

import '../theme/cosmos_theme.dart';

/// Tracking status of a near-Earth object. Lives in the model so both the
/// list cards, the detail screen and the filter screen can share one source.
enum AsteroidStatus {
  closeApproach('CLOSE APPROACH'),
  monitoring('MONITORING'),
  nominal('NOMINAL');

  const AsteroidStatus(this.label);
  final String label;

  Color get dotColor {
    switch (this) {
      case AsteroidStatus.closeApproach:
        return CosmosColors.error;
      case AsteroidStatus.monitoring:
        return CosmosColors.secondary;
      case AsteroidStatus.nominal:
        return CosmosColors.outline;
    }
  }
}

/// A single tracked near-Earth object. Passed between screens as a named-route
/// argument, so it is a plain immutable value object.
class Asteroid {
  const Asteroid({
    required this.designation,
    required this.status,
    required this.velocity,
    required this.diameter,
    required this.missDistance,
    required this.magnitude,
    required this.firstObserved,
    required this.briefing,
  });

  final String designation;
  final AsteroidStatus status;
  final String velocity;
  final String diameter;
  final String missDistance;
  final String magnitude;
  final String firstObserved;
  final String briefing;
}

/// Mocked local catalogue — no backend required (allowed by the brief).
const kAsteroids = <Asteroid>[
  Asteroid(
    designation: '99942 Apophis',
    status: AsteroidStatus.closeApproach,
    velocity: '30.73 km/s',
    diameter: '370 m',
    missDistance: '0.00021 AU',
    magnitude: '19.7',
    firstObserved: '2004-06-19',
    briefing:
        'Discovered in 2004, Apophis briefly held the highest impact '
        'probability ever recorded before refined observations ruled out a '
        'collision through 2116. It remains a flagship close-approach target.',
  ),
  Asteroid(
    designation: '101955 Bennu',
    status: AsteroidStatus.monitoring,
    velocity: '27.88 km/s',
    diameter: '490 m',
    missDistance: '0.05210 AU',
    magnitude: '20.9',
    firstObserved: '1999-09-11',
    briefing:
        'Bennu is a carbon-rich rubble pile sampled by OSIRIS-REx in 2020. '
        'Its slightly chaotic orbit keeps it under long-term monitoring for '
        'late-22nd-century approaches.',
  ),
  Asteroid(
    designation: '2023 DZ2',
    status: AsteroidStatus.nominal,
    velocity: '15.42 km/s',
    diameter: '60 m',
    missDistance: '0.10400 AU',
    magnitude: '24.1',
    firstObserved: '2023-02-27',
    briefing:
        'A small but bright object that made a well-observed flyby in 2023, '
        'serving as a coordinated planetary-defence observation rehearsal.',
  ),
  Asteroid(
    designation: '3122 Florence',
    status: AsteroidStatus.nominal,
    velocity: '13.53 km/s',
    diameter: '4.4 km',
    missDistance: '0.04723 AU',
    magnitude: '14.1',
    firstObserved: '1981-03-02',
    briefing:
        'One of the largest near-Earth asteroids known to come this close. '
        'Radar imaging in 2017 revealed two tiny moons orbiting it.',
  ),
];
