import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/growth_stage.dart';

/// Holds the user's streak. Seeded with sample data for the MVP.
class StreakNotifier extends Notifier<StreakState> {
  @override
  StreakState build() => const StreakState(currentStreak: 5, bestStreak: 12);
}

final streakProvider =
    NotifierProvider<StreakNotifier, StreakState>(StreakNotifier.new);
