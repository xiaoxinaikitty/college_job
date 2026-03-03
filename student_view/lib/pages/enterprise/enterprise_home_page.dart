import 'package:flutter/material.dart';

import '../../models/account_role.dart';
import '../../routes/app_routes.dart';
import '../../routes/route_args.dart';

class EnterpriseHomePage extends StatelessWidget {
  const EnterpriseHomePage({
    super.key,
    required this.args,
  });

  final DashboardRouteArgs args;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEAF2FF),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        '企业工作台',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.login,
                          (route) => false,
                          arguments: LoginRouteArgs(
                            baseUrl: args.baseUrl,
                            role: AccountRole.enterprise,
                          ),
                        );
                      },
                      icon: const Icon(Icons.logout_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B5FFF),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    '已登录企业账号，用户ID: ${args.payload.userId}\n企业端页面可在此继续扩展：岗位发布、筛选简历、安排面试、发放Offer。',
                    style: const TextStyle(
                      color: Colors.white,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  '当前已完成学生/企业登录分流。',
                  style: TextStyle(color: Color(0xFF4D5A72)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
