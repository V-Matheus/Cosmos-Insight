import 'package:flutter/material.dart';

/// Switches between a "mobile" and a "desktop" layout based on the width the
/// parent makes available — measured with [LayoutBuilder] (NOT the full screen
/// size), so it also reacts to side panels, split views and embedded usage.
///
/// ```dart
/// ResponsiveLayout(
///   mobile: (context) => const MobileLayout(),
///   desktop: (context) => const DesktopLayout(),
/// )
/// ```
///
/// The [breakpoint] is the boundary in logical pixels: anything strictly below
/// it renders [mobile], anything at or above renders [desktop]. The optional
/// [tablet] builder, when provided, fills the band between [breakpoint] and
/// [desktopBreakpoint].
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.desktop,
    this.tablet,
    this.breakpoint = 600,
    this.desktopBreakpoint = 1100,
  });

  /// Built when the available width is `< breakpoint`.
  final WidgetBuilder mobile;

  /// Built when the available width is `>= breakpoint` (and, if [tablet] is
  /// given, `>= desktopBreakpoint`).
  final WidgetBuilder desktop;

  /// Optional middle layout for the `[breakpoint, desktopBreakpoint)` band.
  /// Falls back to [desktop] when null.
  final WidgetBuilder? tablet;

  /// Width (logical px) separating [mobile] from the wider layouts.
  final double breakpoint;

  /// Width (logical px) separating [tablet] from [desktop].
  final double desktopBreakpoint;

  /// Convenience check for callers that need to branch on the same rule
  /// without rebuilding through this widget, e.g. `ResponsiveLayout.isMobile(context)`.
  static bool isMobile(BuildContext context, {double breakpoint = 600}) =>
      MediaQuery.sizeOf(context).width < breakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width < breakpoint) {
          return mobile(context);
        }
        if (tablet != null && width < desktopBreakpoint) {
          return tablet!(context);
        }
        return desktop(context);
      },
    );
  }
}
