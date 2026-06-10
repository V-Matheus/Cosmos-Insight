import 'package:flutter/material.dart';

import 'routes/app_routes.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/cosmos_theme.dart';

void main() => runApp(const CosmosInsightApp());

class CosmosInsightApp extends StatelessWidget {
  const CosmosInsightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cosmos Insight',
      debugShowCheckedModeBanner: false,
      theme: CosmosTheme.dark(),

      // Requirement (1): centralized named routes registered on the ROOT
      // navigator. The shell hosts the BottomNavigationBar + per-tab nested
      // navigators; `settings` is pushed above the shell from the Drawer.
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.shell: (_) => const HomeScreen(),
        AppRoutes.settings: (_) => const SettingsScreen(),
      },
    );
  }
}
