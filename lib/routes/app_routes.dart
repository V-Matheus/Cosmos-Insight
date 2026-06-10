import 'package:flutter/material.dart';

import '../models/asteroid.dart';
import '../screens/asteroid_detail_screen.dart';
import '../screens/asteroid_filter_screen.dart';
import '../screens/asteroids_view.dart';
import '../screens/placeholder_view.dart';
import '../screens/telescope_screen.dart';

/// Single source of truth for every route name in the app.
///
/// Top-level routes ([login], [shell], [settings]) are registered in the
/// `MaterialApp.routes` map and live on the ROOT navigator. The tab-internal
/// routes are resolved by [AppRouter.onGenerateTabRoute] inside each tab's own
/// nested Navigator, so every tab keeps an independent history stack.
class AppRoutes {
  AppRoutes._();

  // --- Root navigator (registered in MaterialApp) ---
  static const login = '/login';
  static const shell = '/shell';
  static const settings = '/settings';

  // --- Tab-internal (resolved by the nested Navigators) ---
  static const todayHome = '/today';
  static const asteroidsHome = '/asteroids';
  static const feedHome = '/feed';
  static const galleryHome = '/gallery';

  static const asteroidDetail = '/asteroids/detail';
  static const asteroidFilter = '/asteroids/filter';
}

/// Resolves the named routes that live INSIDE a tab's nested Navigator.
///
/// Keeping this in one place is what requirement (1) — "centralized named
/// routes" — is about: a screen never hard-codes how another screen is built,
/// it just asks for a route name and (optionally) passes `arguments`.
class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateTabRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.todayHome:
        return _page(
          settings,
          const PlaceholderView(
            title: "Today's Sky",
            icon: Icons.wb_twilight,
            message:
                'Daily ephemeris feed coming online. Stay tuned for sunrise '
                'and visibility windows.',
          ),
        );

      case AppRoutes.asteroidsHome:
        return _page(settings, const AsteroidsView());

      case AppRoutes.feedHome:
        return _page(settings, const TelescopeScreen());

      case AppRoutes.galleryHome:
        return _page(
          settings,
          const PlaceholderView(
            title: 'Gallery',
            icon: Icons.photo_library_outlined,
            message:
                'Curated imagery from observatory archives will appear here '
                'once the link is up.',
          ),
        );

      // Requirement (4): screen built from arguments passed on a named route.
      case AppRoutes.asteroidDetail:
        final asteroid = settings.arguments as Asteroid;
        return _page(settings, AsteroidDetailScreen(asteroid: asteroid));

      // Requirement (5): this screen pops with a result (an AsteroidStatus?).
      case AppRoutes.asteroidFilter:
        final current = settings.arguments as AsteroidStatus?;
        return _page(settings, AsteroidFilterScreen(current: current));

      default:
        return _page(
          settings,
          Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(child: Text('Unknown route: ${settings.name}')),
          ),
        );
    }
  }

  static MaterialPageRoute<dynamic> _page(
    RouteSettings settings,
    Widget child,
  ) {
    return MaterialPageRoute<dynamic>(
      builder: (_) => child,
      settings: settings,
    );
  }
}
