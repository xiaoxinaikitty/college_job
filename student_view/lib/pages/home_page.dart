import 'package:flutter/material.dart';

import '../models/account_role.dart';
import '../routes/app_routes.dart';
import '../routes/route_args.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.args,
  });

  final DashboardRouteArgs args;

  @override
  Widget build(BuildContext context) {
    final payload = args.payload;
    return Scaffold(
      appBar: AppBar(
        title: const Text('实习通'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout_rounded),
            tooltip: '退出登录',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '登录成功',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 18),
            _infoTile('账号类型', args.role.label),
            _infoTile('用户ID', '${payload.userId}'),
            _infoTile('企业ID', payload.enterpriseId?.toString() ?? '-'),
            _infoTile(
              '访问令牌',
              payload.accessToken.length > 42
                  ? '${payload.accessToken.substring(0, 42)}...'
                  : payload.accessToken,
            ),
            const SizedBox(height: 16),
            const Text(
              '下一步可以将此页面替换为学生端/企业端业务首页。',
              style: TextStyle(color: Color(0xFF5A667A)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDCE4F4)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF5B6880),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
