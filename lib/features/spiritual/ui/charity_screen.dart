import 'package:flutter/material.dart';

import '../../../core/widgets/coming_soon_screen.dart';
import '../../../l10n/app_localizations.dart';

class CharityScreen extends StatelessWidget {
  const CharityScreen({super.key});

  @override
  Widget build(BuildContext context) => ComingSoonScreen(
        title: AppLocalizations.of(context).navCharity,
        icon: Icons.volunteer_activism_outlined,
      );
}
