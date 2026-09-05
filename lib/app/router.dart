import 'package:go_router/go_router.dart';

import '../features/dashboard/ui/dashboard_screen.dart';
import '../features/productivity/ui/tasks_screen.dart';
import '../features/spiritual/ui/charity_screen.dart';
import '../features/spiritual/ui/prayer_screen.dart';
import '../features/spiritual/ui/quran_screen.dart';

/// App route paths in one place.
abstract class Routes {
  static const dashboard = '/';
  static const prayer = '/prayer';
  static const quran = '/quran';
  static const charity = '/charity';
  static const tasks = '/tasks';
}

/// Central go_router configuration. The dashboard is the home; the remaining
/// routes point at scaffolded "coming soon" screens for this run.
final appRouter = GoRouter(
  initialLocation: Routes.dashboard,
  routes: [
    GoRoute(
      path: Routes.dashboard,
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: Routes.prayer,
      builder: (context, state) => const PrayerScreen(),
    ),
    GoRoute(
      path: Routes.quran,
      builder: (context, state) => const QuranScreen(),
    ),
    GoRoute(
      path: Routes.charity,
      builder: (context, state) => const CharityScreen(),
    ),
    GoRoute(
      path: Routes.tasks,
      builder: (context, state) => const TasksScreen(),
    ),
  ],
);
