import 'package:flutter/material.dart';

import '../theme/cosmos_theme.dart';
import '../widgets/cosmos_bottom_nav.dart';
import '../widgets/tech_grid_background.dart';
import 'asteroids_view.dart';
import 'placeholder_view.dart';
import 'telescope_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _activeIndex = 1;

  static const _bodies = <Widget>[
    PlaceholderView(
      title: "Today's Sky",
      icon: Icons.wb_twilight,
      message:
          'Daily ephemeris feed coming online. Stay tuned for sunrise and visibility windows.',
    ),
    AsteroidsView(),
    TelescopeScreen(),
    PlaceholderView(
      title: 'Gallery',
      icon: Icons.photo_library_outlined,
      message:
          'Curated imagery from observatory archives will appear here once the link is up.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CosmosColors.background,
      body: TechGridBackground(
        child: SafeArea(
          bottom: false,
          child: _bodies[_activeIndex],
        ),
      ),
      bottomNavigationBar: CosmosBottomNav(
        activeIndex: _activeIndex,
        onTap: (i) => setState(() => _activeIndex = i),
      ),
      extendBody: true,
    );
  }
}
