import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/asteroid.dart';
import '../services/neo_service.dart';
import '../theme/cosmos_theme.dart';
import '../widgets/glass_panel.dart';

class TelescopeScreen extends StatefulWidget {
  const TelescopeScreen({super.key});

  @override
  State<TelescopeScreen> createState() => _TelescopeScreenState();
}

class _TelescopeScreenState extends State<TelescopeScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final NeoService _service = NeoService();

  static final RegExp _dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  bool _isValid = false;
  bool _isLoading = false;
  String? _queriedDate;
  List<Asteroid> _results = const [];
  final Set<String> _flagged = <String>{};
  final Set<String> _expanded = <String>{};

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _service.dispose();
    super.dispose();
  }

  // ---------- TextField: real-time validation ----------
  void _onDateChanged(String value) {
    debugPrint('[neo-feed] date typed: "$value"');
    final valid = _validateDate(value);
    if (valid != _isValid) {
      setState(() => _isValid = valid);
    }
  }

  bool _validateDate(String raw) {
    final v = raw.trim();
    if (!_dateRegex.hasMatch(v)) return false;
    final parts = v.split('-');
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);
    if (month < 1 || month > 12) return false;
    if (day < 1 || day > 31) return false;
    return true;
  }

  // ---------- Button 1: QUERY (validates + SnackBar + chained AlertDialog) ----------
  Future<void> _onQueryPressed() async {
    if (!_isValid || _isLoading) return;
    final date = _controller.text.trim();
    debugPrint('[neo-feed] QUERY pressed: $date');
    _focusNode.unfocus();

    setState(() {
      _isLoading = true;
      _results = const [];
      _flagged.clear();
      _expanded.clear();
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Querying NEO feed for $date...'),
          backgroundColor: CosmosColors.surfaceContainer,
          duration: const Duration(milliseconds: 900),
        ),
      );

    // Hits NASA's NeoWs feed for the date, then chains into the summary dialog.
    List<Asteroid> results;
    try {
      results = await _service.feed(date);
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _queriedDate = date;
        _results = const [];
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: CosmosColors.surfaceContainer,
            duration: const Duration(seconds: 3),
          ),
        );
      return;
    }
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _queriedDate = date;
      _results = results;
    });

    if (results.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('No near-Earth objects reported for $date.'),
            backgroundColor: CosmosColors.surfaceContainer,
            duration: const Duration(milliseconds: 1400),
          ),
        );
      return;
    }

    final hazardous = results.where((r) => r.hazardous).length;
    final closest = results
        .map((r) => r.missDistanceAu)
        .reduce((a, b) => a < b ? a : b);

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CosmosColors.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: CosmosColors.glassBorder),
        ),
        title: Text(
          'FEED RECEIVED',
          style: CosmosTextStyles.labelCaps(
            color: CosmosColors.primaryContainer,
            letterSpacing: 2,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('DATE', date),
            _detailRow('OBJECTS', results.length.toString()),
            _detailRow('HAZARDOUS', hazardous.toString()),
            _detailRow('CLOSEST', '${closest.toStringAsFixed(5)} AU'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'REVIEW',
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

  // ---------- Button 2: CLEAR (different logic: wipes state) ----------
  void _onClearPressed() {
    debugPrint('[neo-feed] CLEAR pressed');
    _controller.clear();
    _focusNode.unfocus();
    setState(() {
      _isValid = false;
      _isLoading = false;
      _queriedDate = null;
      _results = const [];
      _flagged.clear();
      _expanded.clear();
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Feed cleared. Enter a new date to query.'),
          backgroundColor: CosmosColors.surfaceContainer,
          duration: Duration(milliseconds: 1400),
        ),
      );
  }

  // ---------- Gesture: tap card = toggle expand ----------
  void _onCardTap(Asteroid neo) {
    debugPrint('[neo-feed] card tap: ${neo.designation}');
    setState(() {
      if (_expanded.contains(neo.id)) {
        _expanded.remove(neo.id);
      } else {
        _expanded.add(neo.id);
      }
    });
  }

  // ---------- Gesture: long-press card = toggle flag ----------
  void _onCardLongPress(Asteroid neo) {
    debugPrint('[neo-feed] card long-press: ${neo.designation}');
    final wasFlagged = _flagged.contains(neo.id);
    setState(() {
      if (wasFlagged) {
        _flagged.remove(neo.id);
      } else {
        _flagged.add(neo.id);
      }
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            wasFlagged
                ? '${neo.designation} unflagged.'
                : '${neo.designation} flagged for review.',
          ),
          backgroundColor: CosmosColors.surfaceContainer,
          duration: const Duration(milliseconds: 1100),
        ),
      );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: CosmosTextStyles.labelCaps(
                color: CosmosColors.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Expanded(child: Text(value, style: CosmosTextStyles.dataMono())),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      children: [
        Text('NEO Feed Query', style: CosmosTextStyles.displayLg()),
        const SizedBox(height: 12),
        Text(
          "Query the Near-Earth Object catalog by date. Tap a result to "
          "expand details, hold to flag it for review.",
          style: CosmosTextStyles.bodyMd(color: CosmosColors.onSurfaceVariant),
        ),
        const SizedBox(height: 28),
        _QueryPanel(
          controller: _controller,
          focusNode: _focusNode,
          isValid: _isValid,
          isLoading: _isLoading,
          onChanged: _onDateChanged,
          onQuery: _onQueryPressed,
          onClear: _onClearPressed,
        ),
        const SizedBox(height: 24),
        if (_isLoading)
          const _LoadingPanel()
        else if (_results.isEmpty)
          _EmptyState(queriedDate: _queriedDate)
        else ...[
          _ResultsHeader(
            date: _queriedDate ?? '—',
            count: _results.length,
            hazardous: _results.where((r) => r.hazardous).length,
          ),
          const SizedBox(height: 12),
          for (final neo in _results) ...[
            _NeoResultCard(
              neo: neo,
              expanded: _expanded.contains(neo.id),
              flagged: _flagged.contains(neo.id),
              onTap: () => _onCardTap(neo),
              onLongPress: () => _onCardLongPress(neo),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ],
    );
  }
}

// ---------- UI widgets ----------

class _QueryPanel extends StatelessWidget {
  const _QueryPanel({
    required this.controller,
    required this.focusNode,
    required this.isValid,
    required this.isLoading,
    required this.onChanged,
    required this.onQuery,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isValid;
  final bool isLoading;
  final ValueChanged<String> onChanged;
  final VoidCallback onQuery;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'QUERY DATE',
                style: CosmosTextStyles.labelCaps(
                  color: CosmosColors.onSurfaceVariant,
                  letterSpacing: 1.6,
                ),
              ),
              const Spacer(),
              _ValidationDot(valid: isValid),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            focusNode: focusNode,
            onChanged: onChanged,
            keyboardType: TextInputType.number,
            inputFormatters: [_DateMaskFormatter()],
            style: CosmosTextStyles.dataMono(),
            cursorColor: CosmosColors.primaryContainer,
            decoration: InputDecoration(
              hintText: 'YYYY-MM-DD',
              hintStyle: CosmosTextStyles.dataMono(color: CosmosColors.outline),
              filled: true,
              fillColor: CosmosColors.surfaceContainerLow,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(
                  color: CosmosColors.outlineVariant,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(
                  color: CosmosColors.primaryContainer,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isValid
                ? 'Format OK — ready to query the feed.'
                : 'Use ISO date format (e.g., 2024-01-15).',
            style: CosmosTextStyles.bodySm(
              color: isValid
                  ? CosmosColors.primary
                  : CosmosColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'QUERY',
                  icon: Icons.travel_explore,
                  enabled: isValid && !isLoading,
                  primary: true,
                  onPressed: onQuery,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  label: 'CLEAR',
                  icon: Icons.restart_alt,
                  enabled: true,
                  primary: false,
                  onPressed: onClear,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ValidationDot extends StatelessWidget {
  const _ValidationDot({required this.valid});
  final bool valid;

  @override
  Widget build(BuildContext context) {
    final color = valid ? CosmosColors.primaryContainer : CosmosColors.outline;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: valid
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.7),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          valid ? 'VALID' : 'WAITING',
          style: CosmosTextStyles.labelCaps(color: color, letterSpacing: 1.4),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.primary,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool enabled;
  final bool primary;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final fg = !enabled
        ? CosmosColors.outline
        : primary
        ? CosmosColors.background
        : CosmosColors.primaryContainer;
    final bg = !enabled
        ? CosmosColors.surfaceContainerLow
        : primary
        ? CosmosColors.primaryContainer
        : Colors.transparent;
    final border = primary
        ? Colors.transparent
        : (enabled
              ? CosmosColors.primaryContainer.withValues(alpha: 0.6)
              : CosmosColors.outlineVariant);

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: border, width: 1),
      ),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: fg, size: 16),
              const SizedBox(width: 8),
              Text(
                label,
                style: CosmosTextStyles.labelCaps(
                  color: fg,
                  letterSpacing: 1.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: CosmosColors.primaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'CONTACTING CATALOG...',
            style: CosmosTextStyles.labelCaps(
              color: CosmosColors.onSurfaceVariant,
              letterSpacing: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.queriedDate});
  final String? queriedDate;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          Icon(
            queriedDate == null ? Icons.search_outlined : Icons.inbox_outlined,
            color: CosmosColors.outline,
            size: 36,
          ),
          const SizedBox(height: 12),
          Text(
            queriedDate == null
                ? 'No feed loaded.\nEnter a date and run QUERY.'
                : 'No objects for $queriedDate.',
            textAlign: TextAlign.center,
            style: CosmosTextStyles.bodySm(
              color: CosmosColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultsHeader extends StatelessWidget {
  const _ResultsHeader({
    required this.date,
    required this.count,
    required this.hazardous,
  });

  final String date;
  final int count;
  final int hazardous;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'RESULTS — $date',
          style: CosmosTextStyles.labelCaps(
            color: CosmosColors.onSurfaceVariant,
            letterSpacing: 1.6,
          ),
        ),
        const Spacer(),
        Text(
          '$count objects · $hazardous hazardous',
          style: CosmosTextStyles.bodySm(color: CosmosColors.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _NeoResultCard extends StatelessWidget {
  const _NeoResultCard({
    required this.neo,
    required this.expanded,
    required this.flagged,
    required this.onTap,
    required this.onLongPress,
  });

  final Asteroid neo;
  final bool expanded;
  final bool flagged;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: flagged
              ? Border.all(color: CosmosColors.error, width: 1.5)
              : null,
          boxShadow: flagged
              ? [
                  BoxShadow(
                    color: CosmosColors.error.withValues(alpha: 0.25),
                    blurRadius: 14,
                  ),
                ]
              : null,
        ),
        child: GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DESIGNATION',
                          style: CosmosTextStyles.labelCaps(
                            color: CosmosColors.onSurfaceVariant,
                            letterSpacing: 1.6,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          neo.designation,
                          style: CosmosTextStyles.headlineMd(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _HazardPill(hazardous: neo.hazardous),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _MetricCell(
                      label: 'VELOCITY',
                      value: neo.velocity,
                      valueColor: CosmosColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _MetricCell(label: 'EST. DIA.', value: neo.diameter),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.only(top: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: CosmosColors.hairline, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Miss Distance: ',
                              style: CosmosTextStyles.bodySm(
                                color: CosmosColors.onSurfaceVariant,
                              ),
                            ),
                            TextSpan(
                              text: neo.missDistance,
                              style: CosmosTextStyles.dataMono(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Icon(
                      expanded ? Icons.expand_less : Icons.expand_more,
                      color: CosmosColors.primary,
                      size: 18,
                    ),
                  ],
                ),
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                crossFadeState: expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox(width: double.infinity),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ExpandedRow(label: 'MAGNITUDE', value: neo.magnitude),
                      _ExpandedRow(
                        label: 'APPROACH',
                        value: neo.closeApproach ?? '—',
                      ),
                      if (flagged)
                        _ExpandedRow(
                          label: 'STATUS',
                          value: 'FLAGGED FOR REVIEW',
                          valueColor: CosmosColors.error,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                expanded
                    ? 'tap to collapse · hold to ${flagged ? 'unflag' : 'flag'}'
                    : 'tap to expand · hold to ${flagged ? 'unflag' : 'flag'}',
                style: CosmosTextStyles.bodySm(color: CosmosColors.outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12),
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: CosmosColors.hairline, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: CosmosTextStyles.labelCaps(
              color: CosmosColors.onSurfaceVariant,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(value, style: CosmosTextStyles.dataMono(color: valueColor)),
        ],
      ),
    );
  }
}

class _ExpandedRow extends StatelessWidget {
  const _ExpandedRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: CosmosTextStyles.labelCaps(
                color: CosmosColors.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: CosmosTextStyles.dataMono(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _HazardPill extends StatelessWidget {
  const _HazardPill({required this.hazardous});
  final bool hazardous;

  @override
  Widget build(BuildContext context) {
    final color = hazardous ? CosmosColors.error : CosmosColors.outline;
    final fill = hazardous
        ? CosmosColors.error.withValues(alpha: 0.1)
        : CosmosColors.surfaceContainerLow;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: hazardous
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.7),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            hazardous ? 'HAZARDOUS' : 'NOMINAL',
            style: CosmosTextStyles.labelCaps(color: color, letterSpacing: 1.0),
          ),
        ],
      ),
    );
  }
}

/// Formats input as `YYYY-MM-DD`: accepts digits only, auto-inserts hyphens,
/// caps at 8 digits, and clamps month (01..12) and day (01..31) on the fly.
class _DateMaskFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.replaceAll(RegExp(r'\D'), '');
    final digits = raw.substring(0, math.min(raw.length, 8));

    final year = digits.length >= 4 ? digits.substring(0, 4) : null;
    var month = digits.length >= 5
        ? digits.substring(4, math.min(6, digits.length))
        : null;
    var day = digits.length >= 7
        ? digits.substring(6, math.min(8, digits.length))
        : null;

    // Clamp month to 01..12 as the user types.
    if (month != null) {
      if (month.length == 1) {
        if (int.parse(month) > 1) month = '0$month';
      } else {
        var m = int.parse(month);
        if (m == 0) m = 1;
        if (m > 12) m = 12;
        month = m.toString().padLeft(2, '0');
      }
    }

    // Clamp day to 01..31 as the user types.
    if (day != null) {
      if (day.length == 1) {
        if (int.parse(day) > 3) day = '0$day';
      } else {
        var d = int.parse(day);
        if (d == 0) d = 1;
        if (d > 31) d = 31;
        day = d.toString().padLeft(2, '0');
      }
    }

    final buffer = StringBuffer();
    if (year != null) {
      buffer.write(year);
      if (month != null) {
        buffer.write('-');
        buffer.write(month);
        if (day != null) {
          buffer.write('-');
          buffer.write(day);
        }
      }
    } else {
      buffer.write(digits);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
