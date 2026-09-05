import 'package:flutter/material.dart';

import '../../../core/widgets/coming_soon_screen.dart';
import '../../../l10n/app_localizations.dart';

class PrayerScreen extends StatelessWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context) => ComingSoonScreen(
        title: AppLocalizations.of(context).navPrayer,
        icon: Icons.mosque_outlined,
      );
}
