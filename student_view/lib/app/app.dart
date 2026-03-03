import 'package:flutter/material.dart';

import '../routes/app_router.dart';
import '../routes/app_routes.dart';
import 'app_theme.dart';

class InternshipApp extends StatelessWidget {
  const InternshipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '实习通',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
