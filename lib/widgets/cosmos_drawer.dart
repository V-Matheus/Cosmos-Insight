import 'dart:ui';

import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../theme/cosmos_theme.dart';

/// Complementary navigation surface (requirement 2). It demonstrates three
/// DISTINCT navigation decisions from one place:
///
///  * Settings  -> `Navigator.pushNamed`        (stack a new screen)
///  * Logout    -> `Navigator.pushReplacementNamed` (swap the whole stack)
///  * About     -> `showDialog`                  (modal, no route push)
///
/// Every action lives on the ROOT navigator (the Drawer is a child of the
/// shell Scaffold), so Settings appears ABOVE the BottomNavigationBar.
class CosmosDrawer extends StatelessWidget {
  const CosmosDrawer({super.key});

  void _openSettings(BuildContext context) {
    Navigator.of(context).pop(); // close the drawer first
    Navigator.of(context).pushNamed(AppRoutes.settings);
  }

  void _logout(BuildContext context) {
    Navigator.of(context).pop();
    // Swap the entire stack for the login screen — back button can't return.
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  void _showAbout(BuildContext context) {
    Navigator.of(context).pop();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CosmosColors.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: CosmosColors.glassBorder),
        ),
        title: Text(
          'ABOUT',
          style: CosmosTextStyles.labelCaps(
            color: CosmosColors.primaryContainer,
            letterSpacing: 2,
          ),
        ),
        content: Text(
          'Cosmos Insight v1.0.0\n\n'
          'A near-Earth object operations console built to demonstrate '
          'combined Drawer + BottomNavigationBar navigation with independent '
          'per-tab history stacks.',
          style: CosmosTextStyles.bodySm(color: CosmosColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'CLOSE',
              style: CosmosTextStyles.labelCaps(
                color: CosmosColors.primaryContainer,
                letterSpacing: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            color: Colors.black.withValues(alpha: 0.55),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.travel_explore,
                          color: CosmosColors.primaryContainer,
                          size: 32,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'OPERATOR',
                          style: CosmosTextStyles.labelCaps(
                            color: CosmosColors.onSurfaceVariant,
                            letterSpacing: 1.6,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('cmd-7741', style: CosmosTextStyles.headlineMd()),
                      ],
                    ),
                  ),
                  const Divider(color: CosmosColors.hairline, height: 1),
                  const SizedBox(height: 8),
                  _DrawerItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    hint: 'push',
                    onTap: () => _openSettings(context),
                  ),
                  _DrawerItem(
                    icon: Icons.info_outline,
                    label: 'About',
                    hint: 'modal',
                    onTap: () => _showAbout(context),
                  ),
                  const Spacer(),
                  const Divider(color: CosmosColors.hairline, height: 1),
                  _DrawerItem(
                    icon: Icons.logout,
                    label: 'Logout',
                    hint: 'replace',
                    danger: true,
                    onTap: () => _logout(context),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.hint,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final String hint;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? CosmosColors.error : CosmosColors.onSurface;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label, style: CosmosTextStyles.bodyMd(color: color)),
            ),
            Text(
              hint,
              style: CosmosTextStyles.labelCaps(
                color: CosmosColors.outline,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
