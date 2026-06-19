import 'package:flutter/material.dart';

import '../models/asteroid.dart';
import '../routes/app_routes.dart';
import '../services/neo_service.dart';
import '../theme/cosmos_theme.dart';
import '../widgets/asteroid_card.dart';
import '../widgets/glass_panel.dart';
import '../widgets/telemetry_overview.dart';
import 'asteroid_filter_screen.dart';

/// Root screen of the ASTEROIDS tab. It loads the live NEO catalogue from
/// NASA's NeoWs browse endpoint and drives two of the navigation requirements
/// from inside its own nested navigator:
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
  final NeoService _service = NeoService();

  AsteroidStatus? _filter;

  bool _loading = true;
  String? _error;
  List<Asteroid> _asteroids = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final asteroids = await _service.browse();
      if (!mounted) return;
      setState(() {
        _asteroids = asteroids;
        _loading = false;
      });
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<Asteroid> get _visible => _filter == null
      ? _asteroids
      : _asteroids.where((a) => a.status == _filter).toList();

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

  /// Number of card columns to render, derived from the available screen
  /// width via [MediaQuery]. Phones stay single-column; tablets and wider
  /// landscape/desktop viewports spread the cards across 2–3 columns.
  int _columnsFor(double width) {
    if (width >= 1100) return 3;
    if (width >= 700) return 2;
    return 1;
  }

  /// Closest approach across the whole loaded catalogue, formatted for the
  /// telemetry panel ('—' until data is available).
  String get _closestApproach {
    if (_asteroids.isEmpty) return '—';
    final closest = _asteroids
        .map((a) => a.missDistanceAu)
        .reduce((a, b) => a < b ? a : b);
    return '${closest.toStringAsFixed(5)} AU';
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    // MediaQuery drives the responsive layout: the number of columns reacts
    // to the current viewport width (and re-runs on rotation / window resize).
    final width = MediaQuery.sizeOf(context).width;
    final columns = _columnsFor(width);

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      children: [
        Text('Near-Earth Objects', style: CosmosTextStyles.displayLg()),
        const SizedBox(height: 12),
        Text(
          "Live telemetry and tracking data for celestial bodies in proximity "
          "to Earth's orbit, sourced from NASA's NeoWs catalogue. Tap an "
          "object for its full briefing.",
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
        TelemetryOverview(
          trackedObjects: _loading ? '—' : '${_asteroids.length}',
          closestApproach: _loading ? '—' : _closestApproach,
        ),
        const SizedBox(height: 32),
        if (_loading)
          const _LoadingState()
        else if (_error != null)
          _ErrorState(message: _error!, onRetry: _load)
        else if (visible.isEmpty)
          Text(
            _asteroids.isEmpty
                ? 'No objects returned by the catalogue.'
                : 'No objects match this filter.',
            style: CosmosTextStyles.bodyMd(
              color: CosmosColors.onSurfaceVariant,
            ),
          )
        else
          ..._buildCardRows(visible, columns),
      ],
    );
  }

  /// Lays the visible asteroids out in rows of [columns] cards each. With a
  /// single column this is equivalent to the original stacked list; with more
  /// columns each row is an even split of [Expanded] cards, padding the final
  /// row with empty slots so the cards keep a consistent width.
  List<Widget> _buildCardRows(List<Asteroid> visible, int columns) {
    final rows = <Widget>[];
    for (var i = 0; i < visible.length; i += columns) {
      final slice = visible.skip(i).take(columns).toList();
      rows.add(
        Row(
          // Cards size to their natural height; align rows from the top.
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var c = 0; c < columns; c++) ...[
              if (c > 0) const SizedBox(width: 16),
              Expanded(
                child: c < slice.length
                    ? AsteroidCard(
                        designation: slice[c].designation,
                        status: slice[c].status,
                        velocity: slice[c].velocity,
                        diameter: slice[c].diameter,
                        missDistance: slice[c].missDistance,
                        onTap: () => _openDetail(slice[c]),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ],
        ),
      );
      rows.add(const SizedBox(height: 16));
    }
    return rows;
  }
}

/// Loading placeholder shown while the NeoWs catalogue is being fetched.
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: CosmosColors.primaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'LOADING CATALOGUE...',
            style: CosmosTextStyles.labelCaps(
              color: CosmosColors.onSurfaceVariant,
              letterSpacing: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}

/// Error panel with a retry affordance, shown when the NeoWs request fails.
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          const Icon(
            Icons.satellite_alt_outlined,
            color: CosmosColors.error,
            size: 40,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: CosmosTextStyles.bodyMd(
              color: CosmosColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: Text(
              'RETRY',
              style: CosmosTextStyles.labelCaps(letterSpacing: 1.6),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: CosmosColors.primaryContainer,
              side: const BorderSide(color: CosmosColors.primaryContainer),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
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
