import 'package:flutter/material.dart';

import '../theme/cosmos_theme.dart';
import '../widgets/glass_panel.dart';
import '../widgets/tech_grid_background.dart';

/// Pushed onto the ROOT navigator from the Drawer (`pushNamed`), so it covers
/// the whole screen — including the BottomNavigationBar. Its own back button
/// (and the OS back) simply `pop()` back to the shell.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _hazardAlerts = true;
  bool _telemetryStream = true;
  bool _reducedMotion = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CosmosColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'SETTINGS',
          style: CosmosTextStyles.labelCaps(letterSpacing: 2),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: TechGridBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            children: [
              GlassPanel(
                child: Column(
                  children: [
                    _SettingToggle(
                      icon: Icons.warning_amber_rounded,
                      label: 'Hazard alerts',
                      value: _hazardAlerts,
                      onChanged: (v) => setState(() => _hazardAlerts = v),
                    ),
                    const Divider(color: CosmosColors.hairline, height: 24),
                    _SettingToggle(
                      icon: Icons.sensors,
                      label: 'Live telemetry stream',
                      value: _telemetryStream,
                      onChanged: (v) => setState(() => _telemetryStream = v),
                    ),
                    const Divider(color: CosmosColors.hairline, height: 24),
                    _SettingToggle(
                      icon: Icons.motion_photos_off_outlined,
                      label: 'Reduced motion',
                      value: _reducedMotion,
                      onChanged: (v) => setState(() => _reducedMotion = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Preferences are mocked locally for this demo. Tap the back '
                'arrow (or use the system back button) to return to the '
                'console — your tab history is preserved.',
                style: CosmosTextStyles.bodySm(
                  color: CosmosColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingToggle extends StatelessWidget {
  const _SettingToggle({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: CosmosColors.primary, size: 22),
        const SizedBox(width: 16),
        Expanded(child: Text(label, style: CosmosTextStyles.bodyMd())),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: CosmosColors.background,
          activeTrackColor: CosmosColors.primaryContainer,
        ),
      ],
    );
  }
}
