import 'package:flutter/material.dart';

import '../../../core/widgets/coming_soon_screen.dart';
import '../../../l10n/app_localizations.dart';

class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context) => ComingSoonScreen(
        title: AppLocalizations.of(context).navQuran,
        icon: Icons.menu_book_outlined,
      );
}
