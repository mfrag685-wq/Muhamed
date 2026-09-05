import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/prayer.dart';
import '../models/spiritual_state.dart';

/// Holds today's spiritual activity. Seeded with sample data for the MVP.
class SpiritualNotifier extends Notifier<SpiritualState> {
  @override
  SpiritualState build() {
    return const SpiritualState(
      prayers: [
        PrayerStatus(name: PrayerName.fajr, done: true),
        PrayerStatus(name: PrayerName.dhuhr, done: true),
        PrayerStatus(name: PrayerName.asr, done: true),
        PrayerStatus(name: PrayerName.maghrib, done: false),
        PrayerStatus(name: PrayerName.isha, done: false),
      ],
      quranPagesDone: 3,
      quranPagesGoal: 5,
      charityDone: 20,
      charityGoal: 50,
      dhikrCount: 33,
    );
  }

  /// Toggle whether a given prayer has been performed today.
  void togglePrayer(PrayerName name) {
    state = state.copyWith(
      prayers: [
        for (final p in state.prayers)
          if (p.name == name) p.copyWith(done: !p.done) else p,
      ],
    );
  }

  void incrementDhikr() =>
      state = state.copyWith(dhikrCount: state.dhikrCount + 1);

  void resetDhikr() => state = state.copyWith(dhikrCount: 0);
}

final spiritualProvider =
    NotifierProvider<SpiritualNotifier, SpiritualState>(SpiritualNotifier.new);

/// Convenience selector: today's overall spiritual completion (0..1).
final spiritualCompletionProvider = Provider<double>(
  (ref) => ref.watch(spiritualProvider).completion,
);
