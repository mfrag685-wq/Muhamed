import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../gamification/models/growth_stage.dart';
import '../../../gamification/providers/gamification_providers.dart';

/// The streak strip: current streak plus a "growth" plant that literally grows
/// taller and leafier with consecutive days — the gamification metaphor.
class StreakStrip extends ConsumerWidget {
  const StreakStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final streak = ref.watch(streakProvider);

    // Overall growth 0..1 across the whole journey (seed -> flourishing).
    final growth = (streak.currentStreak / 30).clamp(0.0, 1.0);

    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            _GrowthPlant(growth: growth, stage: streak.stage),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_fire_department,
                          color: scheme.onPrimaryContainer, size: 20),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        l10n.streakTitle,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.streakDays(streak.currentStreak),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.streakKeepGrowing,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          scheme.onPrimaryContainer.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GrowthPlant extends StatelessWidget {
  const _GrowthPlant({required this.growth, required this.stage});

  final double growth;
  final GrowthStage stage;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 64,
      height: 72,
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: growth),
        duration: const Duration(milliseconds: 1100),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) => CustomPaint(
          painter: _PlantPainter(growth: value, stage: stage),
        ),
      ),
    );
  }
}

/// Draws a simple, friendly plant: a pot, a stem that lengthens with growth,
/// and a number of leaves / a canopy that fills in at later stages.
class _PlantPainter extends CustomPainter {
  _PlantPainter({required this.growth, required this.stage});

  final double growth;
  final GrowthStage stage;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final baseX = w / 2;
    final soilY = h - 14;

    // Pot / soil
    final potPaint = Paint()..color = AppColors.soil;
    final potPath = Path()
      ..moveTo(baseX - 12, soilY)
      ..lineTo(baseX + 12, soilY)
      ..lineTo(baseX + 9, h - 2)
      ..lineTo(baseX - 9, h - 2)
      ..close();
    canvas.drawPath(potPath, potPaint);

    if (growth <= 0.001) {
      // Seed: a small dot resting on the soil.
      canvas.drawCircle(
          Offset(baseX, soilY - 3), 3, Paint()..color = AppColors.growthStem);
      return;
    }

    // Stem
    final stemHeight = (soilY - 8) * growth;
    final topY = soilY - stemHeight;
    final stemPaint = Paint()
      ..color = AppColors.growthStem
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(baseX, soilY), Offset(baseX, topY), stemPaint);

    // Leaves — count scales with growth stage.
    final leafPaint = Paint()..color = AppColors.growthLeaf;
    final leafCount = switch (stage) {
      GrowthStage.seed => 0,
      GrowthStage.sprout => 2,
      GrowthStage.seedling => 3,
      GrowthStage.sapling => 4,
      GrowthStage.tree => 5,
      GrowthStage.flourishing => 6,
    };

    for (var i = 0; i < leafCount; i++) {
      final along = (i + 1) / (leafCount + 1);
      final y = soilY - stemHeight * along;
      final left = i.isEven;
      _drawLeaf(canvas, Offset(baseX, y), left, leafPaint, 6 + growth * 3);
    }

    // Canopy for mature stages.
    if (stage == GrowthStage.tree || stage == GrowthStage.flourishing) {
      canvas.drawCircle(Offset(baseX, topY), 9 + growth * 3, leafPaint);
    }
    if (stage == GrowthStage.flourishing) {
      // A small gold blossom to mark a flourishing streak.
      canvas.drawCircle(
          Offset(baseX, topY), 3, Paint()..color = AppColors.seedSand);
    }
  }

  void _drawLeaf(
      Canvas canvas, Offset base, bool left, Paint paint, double len) {
    final dir = left ? -1 : 1;
    final path = Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(
        base.dx + dir * len,
        base.dy - len,
        base.dx + dir * len * 1.4,
        base.dy - len * 0.2,
      )
      ..quadraticBezierTo(
        base.dx + dir * len,
        base.dy + len * 0.2,
        base.dx,
        base.dy,
      )
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PlantPainter old) =>
      old.growth != growth || old.stage != stage;
}
