import 'package:flutter/material.dart';

import '../theme/cosmos_theme.dart';

/// Tracking status of a near-Earth object. Lives in the model so both the
/// list cards, the detail screen and the filter screen can share one source.
///
/// Derived from the NeoWs flags: a potentially hazardous object surfaces as a
/// [closeApproach], a Sentry-tracked object as [monitoring], everything else
/// as [nominal].
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

/// A single near-Earth object as returned by NASA's NeoWs API.
///
/// Numeric fields hold the raw values (so screens can sort/compare), while the
/// formatted [velocity], [diameter], [missDistance], etc. getters render them
/// for display. Passed between screens as a named-route argument, so it is a
/// plain immutable value object.
class Asteroid {
  const Asteroid({
    required this.id,
    required this.designation,
    required this.hazardous,
    required this.sentry,
    required this.velocityKps,
    required this.diameterMeters,
    required this.missDistanceAu,
    required this.absoluteMagnitude,
    this.firstObservationDate,
    this.closeApproach,
  });

  final String id;
  final String designation;
  final bool hazardous;
  final bool sentry;

  /// Relative velocity of the chosen close approach, in km/s.
  final double velocityKps;

  /// Average of the estimated min/max diameter, in metres.
  final double diameterMeters;

  /// Miss distance of the chosen close approach, in astronomical units.
  final double missDistanceAu;

  /// Absolute magnitude (H).
  final double absoluteMagnitude;

  /// First observation date (`YYYY-MM-DD`), present only on the browse
  /// endpoint, which includes `orbital_data`. Null for feed results.
  final String? firstObservationDate;

  /// Full close-approach timestamp of the chosen approach
  /// (e.g. `2029-Apr-13 21:42`), when available.
  final String? closeApproach;

  AsteroidStatus get status {
    if (hazardous) return AsteroidStatus.closeApproach;
    if (sentry) return AsteroidStatus.monitoring;
    return AsteroidStatus.nominal;
  }

  String get velocity => '${velocityKps.toStringAsFixed(2)} km/s';

  String get diameter => diameterMeters >= 1000
      ? '${(diameterMeters / 1000).toStringAsFixed(1)} km'
      : '${diameterMeters.round()} m';

  String get missDistance => '${missDistanceAu.toStringAsFixed(5)} AU';

  String get magnitude => absoluteMagnitude.toStringAsFixed(1);

  String get firstObserved => firstObservationDate ?? '—';

  /// Synthesised one-paragraph summary from the live data — NeoWs has no free
  /// text description, so the detail screen builds its briefing from the
  /// numbers and flags we actually fetched.
  String get briefing {
    final hazardSentence = hazardous
        ? 'It is classified as a potentially hazardous asteroid, keeping it on '
              'active planetary-defence watch lists.'
        : sentry
        ? 'It is tracked by the Sentry impact-monitoring system, though no '
              'significant impact risk is currently flagged.'
        : 'Current observations place it on a nominal trajectory with no '
              'elevated risk.';
    return '$designation is a near-Earth object roughly $diameter across. Its '
        'reference close approach brings it within $missDistance of Earth, '
        'travelling at $velocity. $hazardSentence';
  }

  /// Builds an [Asteroid] from a single NeoWs object node.
  ///
  /// NeoWs ships an object with an array of `close_approach_data`. The feed
  /// endpoint already filters that array to the queried date (so we take the
  /// first entry), whereas browse returns the full history — pass
  /// [closest] to surface the nearest approach instead.
  factory Asteroid.fromJson(
    Map<String, dynamic> json, {
    bool closest = false,
  }) {
    final approaches = (json['close_approach_data'] as List?) ?? const [];
    final approach = _pickApproach(approaches, closest: closest);

    final meters =
        (json['estimated_diameter'] as Map?)?['meters'] as Map? ?? const {};
    final dMin = _toDouble(meters['estimated_diameter_min']);
    final dMax = _toDouble(meters['estimated_diameter_max']);

    return Asteroid(
      id:
          json['id']?.toString() ??
          json['neo_reference_id']?.toString() ??
          '',
      designation: (json['name'] as String?)?.trim() ?? 'Unknown object',
      hazardous: json['is_potentially_hazardous_asteroid'] == true,
      sentry: json['is_sentry_object'] == true,
      velocityKps: _toDouble(
        (approach?['relative_velocity'] as Map?)?['kilometers_per_second'],
      ),
      diameterMeters: (dMin + dMax) / 2,
      missDistanceAu: _toDouble(
        (approach?['miss_distance'] as Map?)?['astronomical'],
      ),
      absoluteMagnitude: _toDouble(json['absolute_magnitude_h']),
      firstObservationDate:
          (json['orbital_data'] as Map?)?['first_observation_date'] as String?,
      closeApproach:
          approach?['close_approach_date_full'] as String? ??
          approach?['close_approach_date'] as String?,
    );
  }

  /// Selects the relevant close-approach entry: the nearest by miss distance
  /// when [closest] is set (browse history), otherwise the first (feed).
  static Map<String, dynamic>? _pickApproach(
    List<dynamic> approaches, {
    required bool closest,
  }) {
    if (approaches.isEmpty) return null;
    final typed = approaches.cast<Map<String, dynamic>>();
    if (!closest) return typed.first;
    return typed.reduce((a, b) {
      final da = _toDouble((a['miss_distance'] as Map?)?['astronomical']);
      final db = _toDouble((b['miss_distance'] as Map?)?['astronomical']);
      return da <= db ? a : b;
    });
  }

  /// NeoWs mixes numbers and numeric strings; normalise both to [double].
  static double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}
