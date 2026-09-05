import 'package:flutter/foundation.dart';

import 'prayer.dart';

/// Immutable snapshot of today's spiritual activity.
///
/// This is in-memory sample state for the MVP dashboard; it will later be
/// backed by Isar. The [completion] getter feeds the Life Balance Score.
@immutable
class SpiritualState {
  const SpiritualState({
    required this.prayers,
    required this.quranPagesDone,
    required this.quranPagesGoal,
    required this.charityDone,
    required this.charityGoal,
    required this.dhikrCount,
  });

  final List<PrayerStatus> prayers;
  final int quranPagesDone;
  final int quranPagesGoal;
  final int charityDone;
  final int charityGoal;
  final int dhikrCount;

  int get prayersDone => prayers.where((p) => p.done).length;

  double get prayerCompletion =>
      prayers.isEmpty ? 0 : prayersDone / prayers.length;

  double get quranCompletion =>
      quranPagesGoal == 0 ? 0 : (quranPagesDone / quranPagesGoal).clamp(0, 1);

  double get charityCompletion =>
      charityGoal == 0 ? 0 : (charityDone / charityGoal).clamp(0, 1);

  /// Overall spiritual completion (0..1): an even blend of the three pillars.
  /// Dhikr is intentionally excluded from the score — it's a free-form,
  /// open-ended act of remembrance rather than a bounded daily goal.
  double get completion =>
      (prayerCompletion + quranCompletion + charityCompletion) / 3;

  SpiritualState copyWith({
    List<PrayerStatus>? prayers,
    int? quranPagesDone,
    int? quranPagesGoal,
    int? charityDone,
    int? charityGoal,
    int? dhikrCount,
  }) {
    return SpiritualState(
      prayers: prayers ?? this.prayers,
      quranPagesDone: quranPagesDone ?? this.quranPagesDone,
      quranPagesGoal: quranPagesGoal ?? this.quranPagesGoal,
      charityDone: charityDone ?? this.charityDone,
      charityGoal: charityGoal ?? this.charityGoal,
      dhikrCount: dhikrCount ?? this.dhikrCount,
    );
  }
}
