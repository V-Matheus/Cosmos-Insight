import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../theme/cosmos_theme.dart';
import '../widgets/glass_panel.dart';
import '../widgets/tech_grid_background.dart';

/// Entry screen. "Logging in" does a [Navigator.pushReplacement] to the shell,
/// so the login page is removed from the stack and the OS back button cannot
/// return to it — this is the canonical use-case for `pushReplacement`.
///
/// Logout (in the Drawer) does the exact mirror: `pushReplacement` back here.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _enter(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(AppRoutes.shell);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CosmosColors.background,
      body: TechGridBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: GlassPanel(
                padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.travel_explore,
                      color: CosmosColors.primaryContainer,
                      size: 48,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'COSMOS INSIGHT',
                      textAlign: TextAlign.center,
                      style: CosmosTextStyles.labelCaps(
                        color: CosmosColors.primaryContainer,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Near-Earth Operations Console',
                      textAlign: TextAlign.center,
                      style: CosmosTextStyles.bodySm(
                        color: CosmosColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const _MockField(label: 'OPERATOR ID', value: 'cmd-7741'),
                    const SizedBox(height: 14),
                    const _MockField(label: 'ACCESS KEY', value: '••••••••'),
                    const SizedBox(height: 28),
                    Material(
                      color: CosmosColors.primaryContainer,
                      borderRadius: BorderRadius.circular(6),
                      child: InkWell(
                        onTap: () => _enter(context),
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.login,
                                color: CosmosColors.background,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'ENTER CONSOLE',
                                style: CosmosTextStyles.labelCaps(
                                  color: CosmosColors.background,
                                  letterSpacing: 1.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MockField extends StatelessWidget {
  const _MockField({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      // stretch makes the field box fill the panel's full width instead of
      // shrinking to fit its text.
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          textAlign: TextAlign.left,
          style: CosmosTextStyles.labelCaps(
            color: CosmosColors.onSurfaceVariant,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: CosmosColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: CosmosColors.outlineVariant),
          ),
          child: Text(value, style: CosmosTextStyles.dataMono()),
        ),
      ],
    );
  }
}
