import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../routes/app_routes.dart';
import '../state/watchlist_model.dart';
import '../theme/cosmos_theme.dart';
import '../widgets/cosmos_bottom_nav.dart';
import '../widgets/cosmos_drawer.dart';
import '../widgets/cosmos_nav_rail.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/tech_grid_background.dart';

/// The application shell: it owns the [Drawer] and the [BottomNavigationBar],
/// and hosts ONE nested [Navigator] per tab inside an [IndexedStack].
///
/// Why this shape:
///  * [IndexedStack] keeps every tab's widget subtree alive, so switching tabs
///    preserves scroll position AND the nested navigator's route stack
///    (requirement 3).
///  * Each tab has its own [GlobalKey] + [Navigator], giving it an independent
///    history. The [PopScope] then routes the OS back button to the *active*
///    tab's navigator first (requirement 6).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _activeIndex = 1; // start on ASTEROIDS

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // One navigator key per tab — the handle to each independent history stack.
  final List<GlobalKey<NavigatorState>> _navKeys = List.generate(
    4,
    (_) => GlobalKey<NavigatorState>(),
  );

  // The root route each tab's navigator opens on.
  static const _tabRoots = [
    AppRoutes.todayHome,
    AppRoutes.asteroidsHome,
    AppRoutes.feedHome,
    AppRoutes.galleryHome,
  ];

  void _onTabTapped(int index) {
    if (index == _activeIndex) {
      // Re-tapping the active tab pops it back to its root — a common and
      // expected gesture that also shows the nested stack at work.
      _navKeys[index].currentState?.popUntil((r) => r.isFirst);
    } else {
      setState(() => _activeIndex = index);
    }
  }

  // Requirement (6): give the active tab's navigator first chance at "back".
  void _handleBack(bool didPop, Object? result) {
    if (didPop) return;
    final nav = _navKeys[_activeIndex].currentState;
    if (nav != null && nav.canPop()) {
      nav.pop();
    } else if (_activeIndex != 0) {
      // At a tab root: fall back to the first tab instead of leaving the app.
      setState(() => _activeIndex = 0);
    } else {
      // First tab, nothing to pop: send the app to the background.
      SystemNavigator.pop();
    }
  }

  // The shared tab content (one live navigator per tab). Built once and reused
  // by both the mobile and the desktop layout — the navigator GlobalKeys keep
  // each tab's history alive regardless of which chrome wraps it.
  Widget get _tabStack => IndexedStack(
    index: _activeIndex,
    children: [
      for (var i = 0; i < _tabRoots.length; i++)
        _TabNavigator(navigatorKey: _navKeys[i], rootRoute: _tabRoots[i]),
    ],
  );

  Widget _header() =>
      _ShellHeader(onMenu: () => _scaffoldKey.currentState?.openDrawer());

  /// Phones: header on top, content in the middle, bottom navigation bar below.
  Widget _mobileLayout(BuildContext context) {
    return Column(
      children: [
        _header(),
        Expanded(child: _tabStack),
        CosmosBottomNav(activeIndex: _activeIndex, onTap: _onTabTapped),
      ],
    );
  }

  /// Tablets / desktop: a vertical navigation rail on the side, content beside it.
  Widget _desktopLayout(BuildContext context) {
    return Row(
      children: [
        CosmosNavRail(activeIndex: _activeIndex, onTap: _onTabTapped),
        Expanded(
          child: Column(
            children: [_header(), Expanded(child: _tabStack)],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _handleBack,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: CosmosColors.background,
        drawer: const CosmosDrawer(),
        body: TechGridBackground(
          child: SafeArea(
            bottom: false,
            // The actual layout switch: < 600px → mobile chrome (bottom nav),
            // >= 600px → desktop chrome (side rail).
            child: ResponsiveLayout(
              mobile: _mobileLayout,
              desktop: _desktopLayout,
            ),
          ),
        ),
      ),
    );
  }
}

/// Wraps a single tab's content in its own [Navigator] so it keeps an
/// independent route stack. All route names are resolved centrally by
/// [AppRouter.onGenerateTabRoute].
class _TabNavigator extends StatelessWidget {
  const _TabNavigator({required this.navigatorKey, required this.rootRoute});

  final GlobalKey<NavigatorState> navigatorKey;
  final String rootRoute;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: AppRouter.onGenerateTabRoute,
      // Build EXACTLY one initial route (the tab root). The default behaviour
      // splits a slash-prefixed name like "/feed" into the path ["/", "/feed"]
      // and generates a route for each segment — which would leave a stray
      // "/" route at the bottom of every tab's stack.
      onGenerateInitialRoutes: (navigator, initialRoute) => [
        AppRouter.onGenerateTabRoute(RouteSettings(name: rootRoute)),
      ],
    );
  }
}

class _ShellHeader extends StatelessWidget {
  const _ShellHeader({required this.onMenu});
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: CosmosColors.onSurface),
            onPressed: onMenu,
            tooltip: 'Open menu',
          ),
          const SizedBox(width: 4),
          Text(
            'COSMOS INSIGHT',
            style: CosmosTextStyles.labelCaps(
              color: CosmosColors.primaryContainer,
              letterSpacing: 2.4,
            ),
          ),
          const Spacer(),
          const _WatchlistBadge(),
          const SizedBox(width: 16),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: CosmosColors.primaryContainer,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: CosmosColors.primaryContainer.withValues(alpha: 0.7),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'LIVE',
            style: CosmosTextStyles.labelCaps(
              color: CosmosColors.onSurfaceVariant,
              letterSpacing: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

/// Watchlist counter shown in the shell header. This widget lives in a totally
/// different part of the tree from the AsteroidCards, yet reacts to the SAME
/// shared state (requirement 3). It consumes via `context.watch`, the second
/// consumption mechanism alongside the cards' `Consumer`.
class _WatchlistBadge extends StatelessWidget {
  const _WatchlistBadge();

  @override
  Widget build(BuildContext context) {
    final count = context.watch<WatchlistModel>().count;
    final active = count > 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          active ? Icons.star : Icons.star_border,
          size: 16,
          color: active
              ? CosmosColors.primaryContainer
              : CosmosColors.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Text(
          '$count',
          style: CosmosTextStyles.labelCaps(
            color: active
                ? CosmosColors.primaryContainer
                : CosmosColors.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
