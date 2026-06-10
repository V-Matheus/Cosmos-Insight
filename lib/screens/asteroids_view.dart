import 'package:flutter/material.dart';

import '../models/asteroid.dart';
import '../routes/app_routes.dart';
import '../theme/cosmos_theme.dart';
import '../widgets/asteroid_card.dart';
import '../widgets/telemetry_overview.dart';
import 'asteroid_filter_screen.dart';

/// Root screen of the ASTEROIDS tab. It drives two of the navigation
/// requirements from inside its own nested navigator:
///
///  * Tapping a card -> `pushNamed(asteroidDetail, arguments: asteroid)`  (4)
///  * Tapping FILTER -> `await pushNamed(asteroidFilter)` then reads the
///    returned [AsteroidStatus?] to filter the list                       (5)
class AsteroidsView extends StatefulWidget {
  const AsteroidsView({super.key});

  @override
  State<AsteroidsView> createState() => _AsteroidsViewState();
}

class _AsteroidsViewState extends State<AsteroidsView> {
  AsteroidStatus? _filter;

  List<Asteroid> get _visible => _filter == null
      ? kAsteroids
      : kAsteroids.where((a) => a.status == _filter).toList();

  void _openDetail(Asteroid asteroid) {
    // Requirement (4): pass the object as the route's arguments.
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.asteroidDetail, arguments: asteroid);
  }

  Future<void> _openFilter() async {
    // Requirement (5): push the centralized named route and await the result
    // the filter screen pops back. A `FilterResult` means the user picked
    // something (possibly "All" => null); anything else means they cancelled.
    //
    // Note: don't parameterize pushNamed<FilterResult?> — the central router
    // builds a MaterialPageRoute<dynamic>, and a typed pushNamed would make
    // Flutter cast it to Route<FilterResult?> and throw. Read the dynamic
    // result and narrow it with `is` instead.
    final result = await Navigator.of(
      context,
    ).pushNamed(AppRoutes.asteroidFilter, arguments: _filter);
    if (!mounted || result is! FilterResult) return;
    setState(() => _filter = result.status);
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      children: [
        Text('Near-Earth Objects', style: CosmosTextStyles.displayLg()),
        const SizedBox(height: 12),
        Text(
          "Real-time telemetry and tracking data for high-velocity "
          "celestial bodies in proximity to Earth's orbit. Tap an object for "
          "its full briefing.",
          style: CosmosTextStyles.bodyMd(color: CosmosColors.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        _FilterBar(
          filter: _filter,
          onTap: _openFilter,
          onClear: _filter == null
              ? null
              : () => setState(() => _filter = null),
        ),
        const SizedBox(height: 24),
        const TelemetryOverview(),
        const SizedBox(height: 32),
        if (visible.isEmpty)
          Text(
            'No objects match this filter.',
            style: CosmosTextStyles.bodyMd(
              color: CosmosColors.onSurfaceVariant,
            ),
          )
        else
          for (final asteroid in visible) ...[
            AsteroidCard(
              designation: asteroid.designation,
              status: asteroid.status,
              velocity: asteroid.velocity,
              diameter: asteroid.diameter,
              missDistance: asteroid.missDistance,
              onTap: () => _openDetail(asteroid),
            ),
            const SizedBox(height: 16),
          ],
      ],
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.filter,
    required this.onTap,
    required this.onClear,
  });

  final AsteroidStatus? filter;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final active = filter != null;
    return Row(
      children: [
        Expanded(
          child: Material(
            color: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: BorderSide(
                color: active
                    ? CosmosColors.primaryContainer
                    : CosmosColors.outlineVariant,
              ),
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_list,
                      size: 16,
                      color: active
                          ? CosmosColors.primaryContainer
                          : CosmosColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      active ? filter!.label : 'FILTER: ALL',
                      style: CosmosTextStyles.labelCaps(
                        color: active
                            ? CosmosColors.primaryContainer
                            : CosmosColors.onSurfaceVariant,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (onClear != null) ...[
          const SizedBox(width: 12),
          IconButton(
            onPressed: onClear,
            icon: const Icon(Icons.close, color: CosmosColors.onSurfaceVariant),
            tooltip: 'Clear filter',
          ),
        ],
      ],
    );
  }
}
