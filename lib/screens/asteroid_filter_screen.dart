import 'package:flutter/material.dart';

import '../models/asteroid.dart';
import '../theme/cosmos_theme.dart';
import '../widgets/glass_panel.dart';

/// The value this screen pops back to the asteroids list. Wrapping the status
/// (which may itself be `null` for "All") lets the caller tell a real pick
/// apart from a plain cancel/back, which pops `null`.
class FilterResult {
  const FilterResult(this.status);
  final AsteroidStatus? status;
}

/// Requirement (5): this screen RETURNS a result to the screen that opened it.
///
/// The asteroids list pushes it with `await Navigator.pushNamed(...)` and reads
/// the [FilterResult] the user picks here, handed back via `Navigator.pop(...)`.
class AsteroidFilterScreen extends StatelessWidget {
  const AsteroidFilterScreen({super.key, required this.current});

  /// The filter currently applied in the list, so we can mark it as selected.
  final AsteroidStatus? current;

  void _select(BuildContext context, AsteroidStatus? value) {
    Navigator.of(context).pop(FilterResult(value)); // <-- pop WITH a result
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          InkWell(
            // Backing out without choosing returns nothing (null result via
            // the system/route default) — the caller keeps its current filter.
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.close,
                    color: CosmosColors.primaryContainer,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'CANCEL',
                    style: CosmosTextStyles.labelCaps(
                      color: CosmosColors.primaryContainer,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Filter Feed', style: CosmosTextStyles.displayLg()),
          const SizedBox(height: 12),
          Text(
            'Pick a status to filter the catalogue. Your choice is sent back '
            'to the list with Navigator.pop(value).',
            style: CosmosTextStyles.bodyMd(
              color: CosmosColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 28),
          _FilterOption(
            label: 'All objects',
            selected: current == null,
            color: CosmosColors.primaryContainer,
            onTap: () => _select(context, null),
          ),
          const SizedBox(height: 12),
          for (final status in AsteroidStatus.values) ...[
            _FilterOption(
              label: status.label,
              selected: current == status,
              color: status.dotColor,
              onTap: () => _select(context, status),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  const _FilterOption({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassPanel(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: CosmosTextStyles.bodyMd())),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected
                  ? CosmosColors.primaryContainer
                  : CosmosColors.outline,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
