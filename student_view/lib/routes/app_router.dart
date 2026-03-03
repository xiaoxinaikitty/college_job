import 'package:flutter/material.dart';

import '../models/account_role.dart';
import '../pages/enterprise/enterprise_home_page.dart';
import '../pages/login_page.dart';
import '../pages/register_page.dart';
import '../pages/student/student_home_page.dart';
import 'app_routes.dart';
import 'route_args.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        final args = settings.arguments as LoginRouteArgs?;
        return MaterialPageRoute(
          builder: (_) => LoginPage(
            initialBaseUrl: args?.baseUrl ?? 'http://localhost:8080',
            initialRole: args?.role ?? AccountRole.student,
          ),
        );
      case AppRoutes.register:
        final args = settings.arguments as RegisterRouteArgs?;
        return MaterialPageRoute(
          builder: (_) => RegisterPage(
            initialBaseUrl: args?.baseUrl ?? 'http://localhost:8080',
            initialRole: args?.role ?? AccountRole.student,
          ),
        );
      case AppRoutes.studentHome:
        final args = settings.arguments as DashboardRouteArgs;
        return MaterialPageRoute(builder: (_) => StudentHomePage(args: args));
      case AppRoutes.enterpriseHome:
        final args = settings.arguments as DashboardRouteArgs;
        return MaterialPageRoute(
            builder: (_) => EnterpriseHomePage(args: args));
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('页面不存在')),
          ),
        );
    }
  }
}
