import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../productivity/providers/productivity_providers.dart';
import '../../spiritual/providers/spiritual_providers.dart';

/// The signature Life Balance Score: a weighted blend of today's spiritual
/// completion and today's task completion, plus a "harmony" penalty so a
/// lopsided day (all worship / no work, or vice-versa) scores below a balanced
/// one. This is what makes Meezan a *balance*, not two separate trackers.
@immutable
class BalanceScore {
  const BalanceScore({
    required this.spiritual,
    required this.worldly,
  });

  /// Spiritual completion, 0..1.
  final double spiritual;

  /// Worldly (task) completion, 0..1.
  final double worldly;

  static const double _spiritualWeight = 0.5;
  static const double _worldlyWeight = 0.5;

  /// How close the two sides are, 0..1 (1 == perfectly balanced).
  double get harmony => 1 - (spiritual - worldly).abs();

  /// Final 0..100 score shown in the centre of the rings.
  ///
  /// 85% weighted blend of the two sides + 15% harmony bonus, so effort on
  /// both fronts is rewarded above equal effort on just one.
  int get score {
    final blend = spiritual * _spiritualWeight + worldly * _worldlyWeight;
    final combined = blend * 0.85 + harmony * 0.15;
    return (combined.clamp(0, 1) * 100).round();
  }
}

/// Live balance score derived from the spiritual and productivity providers.
final balanceScoreProvider = Provider<BalanceScore>((ref) {
  final spiritual = ref.watch(spiritualCompletionProvider);
  final worldly = ref.watch(taskCompletionProvider);
  return BalanceScore(spiritual: spiritual, worldly: worldly);
});
