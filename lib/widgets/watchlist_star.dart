import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/watchlist_model.dart';
import '../theme/cosmos_theme.dart';

/// A star toggle bound to the shared [WatchlistModel].
///
/// Requirement (2): it consumes the state with a [Consumer], so ONLY this
/// button rebuilds when the watchlist changes — not the whole card. The tap
/// delegates to [WatchlistModel.toggle] via `context.read`; the widget holds no
/// state of its own.
class WatchlistStar extends StatelessWidget {
  const WatchlistStar({super.key, required this.designation, this.size = 24});

  final String designation;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Consumer<WatchlistModel>(
      builder: (context, watchlist, _) {
        final watched = watchlist.isWatched(designation);
        return IconButton(
          // read (not watch) — we only need the model to call a method here.
          onPressed: () => context.read<WatchlistModel>().toggle(designation),
          icon: Icon(
            watched ? Icons.star : Icons.star_border,
            color: watched
                ? CosmosColors.primaryContainer
                : CosmosColors.onSurfaceVariant,
            size: size,
          ),
          tooltip: watched ? 'Remove from watchlist' : 'Add to watchlist',
          splashRadius: size,
        );
      },
    );
  }
}
