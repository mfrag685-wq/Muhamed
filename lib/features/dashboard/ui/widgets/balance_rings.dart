import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// The signature Life Balance hero: two concentric rings — an outer
/// **Spiritual** ring and an inner **Worldly** ring — with a single 0–100
/// balance number in the centre. Both rings sweep in from zero on load.
class BalanceRings extends StatefulWidget {
  const BalanceRings({
    super.key,
    required this.score,
    required this.spiritual,
    required this.worldly,
    this.size = 220,
  });

  /// Final balance score, 0..100.
  final int score;

  /// Spiritual completion, 0..1 (outer ring).
  final double spiritual;

  /// Worldly completion, 0..1 (inner ring).
  final double worldly;

  final double size;

  @override
  State<BalanceRings> createState() => _BalanceRingsState();
}

class _BalanceRingsState extends State<BalanceRings>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curve;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  }

  @override
  void didUpdateWidget(covariant BalanceRings oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-run the sweep whenever the underlying values change materially.
    if (oldWidget.spiritual != widget.spiritual ||
        oldWidget.worldly != widget.worldly) {
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final spiritualColor =
        isDark ? AppColors.spiritualRingDark : AppColors.spiritualRing;
    final worldlyColor =
        isDark ? AppColors.worldlyRingDark : AppColors.worldlyRing;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _curve,
        builder: (context, _) {
          final t = _curve.value;
          return CustomPaint(
            painter: _RingsPainter(
              spiritual: widget.spiritual * t,
              worldly: widget.worldly * t,
              spiritualColor: spiritualColor,
              worldlyColor: worldlyColor,
              trackColor: theme.colorScheme.surfaceContainerHighest,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(widget.score * t).round()}',
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.balanceTitle,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  _RingsPainter({
    required this.spiritual,
    required this.worldly,
    required this.spiritualColor,
    required this.worldlyColor,
    required this.trackColor,
  });

  final double spiritual;
  final double worldly;
  final Color spiritualColor;
  final Color worldlyColor;
  final Color trackColor;

  static const double _stroke = 16;
  static const double _gap = 8; // space between the two rings

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = (size.width - _stroke) / 2;
    final innerRadius = outerRadius - _stroke - _gap;

    _drawRing(canvas, center, outerRadius, spiritual, spiritualColor);
    _drawRing(canvas, center, innerRadius, worldly, worldlyColor);
  }

  void _drawRing(
    Canvas canvas,
    Offset center,
    double radius,
    double progress,
    Color color,
  ) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = -math.pi / 2; // 12 o'clock

    // Track
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round
      ..color = trackColor;
    canvas.drawArc(rect, 0, 2 * math.pi, false, trackPaint);

    if (progress <= 0) return;

    // Progress arc with a subtle sweep gradient for depth.
    final sweep = 2 * math.pi * progress.clamp(0, 1);
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + 2 * math.pi,
        colors: [color.withValues(alpha: 0.65), color],
        transform: GradientRotation(startAngle),
      ).createShader(rect);
    canvas.drawArc(rect, startAngle, sweep, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _RingsPainter old) =>
      old.spiritual != spiritual ||
      old.worldly != worldly ||
      old.spiritualColor != spiritualColor ||
      old.worldlyColor != worldlyColor ||
      old.trackColor != trackColor;
}
