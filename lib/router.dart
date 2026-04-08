import 'package:go_router/go_router.dart';

import 'screens/dashboard_screen.dart';
import 'screens/lot_detail_screen.dart';
import 'screens/analytics_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/lot/:id',
      builder: (_, state) =>
          LotDetailScreen(lotId: state.pathParameters['id'] ?? ''),
    ),
    GoRoute(
      path: '/analytics',
      builder: (_, __) => const AnalyticsScreen(),
    ),
  ],
);
