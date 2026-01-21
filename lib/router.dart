import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/login_page.dart';
import 'features/dashboard/dashboard_home_page.dart';
import 'features/dashboard/dashboard_page.dart';
import 'features/lookups/flavour_page.dart';
import 'features/lookups/topping_page.dart';
import 'features/lookups/consistency_page.dart';
import 'features/lookups/restaurant_page.dart';
import 'features/config/config_page.dart';
import 'features/reports/orders_report_page.dart';
import 'features/reports/daily_trend_page.dart';
import 'features/reports/audit_log_page.dart';
import '../features/auth/auth_provider.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final loggedIn = authState != null;
      final loggingIn = state.uri.path == '/login';

      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && loggingIn) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      ShellRoute(
        builder: (context, state, child) => DashboardPage(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardHomePage(), // Now shows charts
          ),
          GoRoute(path: '/flavours', builder: (context, state) => const FlavourPage()),
          GoRoute(path: '/toppings', builder: (context, state) => const ToppingPage()),
          GoRoute(path: '/consistencies', builder: (context, state) => const ConsistencyPage()),
          GoRoute(path: '/restaurants', builder: (context, state) => const RestaurantPage()),
          GoRoute(path: '/config', builder: (context, state) => const ConfigPage()),
          GoRoute(path: '/orders-report', builder: (context, state) => const OrdersReportPage()),
          GoRoute(path: '/daily-trend', builder: (context, state) => const DailyTrendPage()),
          GoRoute(path: '/audit', builder: (context, state) => const AuditLogPage()),
        ],
      ),
    ],
  );
});