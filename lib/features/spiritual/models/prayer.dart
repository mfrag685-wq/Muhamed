import 'package:flutter/widgets.dart';

import '../../../l10n/app_localizations.dart';

/// The five daily obligatory prayers.
enum PrayerName { fajr, dhuhr, asr, maghrib, isha }

extension PrayerNameL10n on PrayerName {
  /// Localised display label for the prayer.
  String label(AppLocalizations l10n) => switch (this) {
        PrayerName.fajr => l10n.prayerFajr,
        PrayerName.dhuhr => l10n.prayerDhuhr,
        PrayerName.asr => l10n.prayerAsr,
        PrayerName.maghrib => l10n.prayerMaghrib,
        PrayerName.isha => l10n.prayerIsha,
      };
}

/// A prayer and whether it has been performed today.
@immutable
class PrayerStatus {
  const PrayerStatus({required this.name, required this.done});

  final PrayerName name;
  final bool done;

  PrayerStatus copyWith({bool? done}) =>
      PrayerStatus(name: name, done: done ?? this.done);
}
