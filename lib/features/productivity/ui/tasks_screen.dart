import 'package:flutter/material.dart';

import '../../../core/widgets/coming_soon_screen.dart';
import '../../../l10n/app_localizations.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) => ComingSoonScreen(
        title: AppLocalizations.of(context).navTasks,
        icon: Icons.checklist_rtl_outlined,
      );
}
