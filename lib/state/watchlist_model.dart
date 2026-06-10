import 'package:flutter/foundation.dart';

/// Shared application state for the operator's asteroid watchlist.
///
/// Requirement (1): the state lives in a class SEPARATE from the UI. No widget
/// owns a `Set` of favourites in its `State` anymore — the single source of
/// truth is this [ChangeNotifier]. Widgets read it and call [toggle]; the model
/// notifies its listeners and every consumer rebuilds reactively.
///
/// This replaces ephemeral `setState` favourites with shared/global state that
/// several widgets in different parts of the tree observe at once:
///  * the star on each AsteroidCard in the list,
///  * the star on the detail screen,
///  * the counter badge in the shell header.
class WatchlistModel extends ChangeNotifier {
  final Set<String> _designations = <String>{};

  /// Read-only view of the watched asteroid designations.
  Set<String> get designations => Set.unmodifiable(_designations);

  /// How many asteroids are currently on the watchlist.
  int get count => _designations.length;

  bool isWatched(String designation) => _designations.contains(designation);

  /// Adds the asteroid if absent, removes it if present, then notifies the UI.
  /// This is the ONLY way the state mutates — the mutation logic lives here,
  /// not in any widget (requirement 5: separation of concerns).
  void toggle(String designation) {
    if (!_designations.remove(designation)) {
      _designations.add(designation);
    }
    notifyListeners();
  }

  void clear() {
    if (_designations.isEmpty) return;
    _designations.clear();
    notifyListeners();
  }
}
