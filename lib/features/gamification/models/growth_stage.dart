import 'package:flutter/foundation.dart';

/// The streak's "growth tree" metaphor: consecutive active days grow a plant
/// from a seed to a flourishing tree. Not generic badges — a living metaphor.
enum GrowthStage { seed, sprout, seedling, sapling, tree, flourishing }

@immutable
class StreakState {
  const StreakState({required this.currentStreak, required this.bestStreak});

  final int currentStreak;
  final int bestStreak;

  /// Maps the current streak length onto a growth stage.
  GrowthStage get stage {
    final d = currentStreak;
    if (d <= 0) return GrowthStage.seed;
    if (d < 3) return GrowthStage.sprout;
    if (d < 7) return GrowthStage.seedling;
    if (d < 14) return GrowthStage.sapling;
    if (d < 30) return GrowthStage.tree;
    return GrowthStage.flourishing;
  }

  /// Progress (0..1) toward the next growth stage — drives the plant animation.
  double get stageProgress {
    const thresholds = [0, 3, 7, 14, 30];
    final d = currentStreak;
    for (var i = 0; i < thresholds.length - 1; i++) {
      if (d < thresholds[i + 1]) {
        final span = thresholds[i + 1] - thresholds[i];
        return ((d - thresholds[i]) / span).clamp(0, 1);
      }
    }
    return 1;
  }

  StreakState copyWith({int? currentStreak, int? bestStreak}) => StreakState(
        currentStreak: currentStreak ?? this.currentStreak,
        bestStreak: bestStreak ?? this.bestStreak,
      );
}
