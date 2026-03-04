import 'package:flutter/material.dart';

import '../../models/account_role.dart';
import '../../routes/app_routes.dart';
import '../../routes/route_args.dart';
import '../../viewmodels/student_home_view_model.dart';
import 'modules/student_applications_module_page.dart';
import 'modules/student_chats_module_page.dart';
import 'modules/student_jobs_module_page.dart';
import 'modules/student_profile_module_page.dart';
import 'modules/student_service_center_module_page.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key, required this.args});

  final DashboardRouteArgs args;

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  late final StudentHomeViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = StudentHomeViewModel(
      baseUrl: widget.args.baseUrl,
      payload: widget.args.payload,
    )..addListener(_onChanged);
    _vm.bootstrap().catchError((e) => _showMessage(e.toString()));
  }

  @override
  void dispose() {
    _vm.removeListener(_onChanged);
    _vm.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0F5FF), Color(0xFFF7FAFF), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _header(),
              _metricRow(),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.82),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(18)),
                    border: Border.all(color: const Color(0xFFDDE7F7)),
                  ),
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(18)),
                    child: _vm.initialLoading
                        ? const Center(child: CircularProgressIndicator())
                        : IndexedStack(
                            index: _vm.tabIndex,
                            children: [
                              StudentJobsModulePage(
                                  vm: _vm, onMessage: _showMessage),
                              StudentApplicationsModulePage(
                                vm: _vm,
                                onMessage: _showMessage,
                              ),
                              StudentChatsModulePage(
                                vm: _vm,
                                baseUrl: widget.args.baseUrl,
                                userId: widget.args.payload.userId,
                              ),
                              StudentServiceCenterModulePage(
                                vm: _vm,
                                onMessage: _showMessage,
                              ),
                              StudentProfileModulePage(
                                vm: _vm,
                                onMessage: _showMessage,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _vm.tabIndex,
        onDestinationSelected: _vm.setTabIndex,
        destinations: [
          NavigationDestination(icon: Icon(Icons.work_outline), label: '岗位'),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            label: '投递',
          ),
          NavigationDestination(
            icon: _badgeIcon(_vm.unreadMessageCount, Icons.chat_bubble_outline),
            label: '消息',
          ),
          NavigationDestination(icon: Icon(Icons.hub_outlined), label: '服务'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: '我的'),
        ],
      ),
    );
  }

  Widget _header() {
    final nickname = widget.args.payload.nickname.trim().isEmpty
        ? '同学'
        : widget.args.payload.nickname.trim();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2159F4), Color(0xFF4A8CFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x242159F4),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.school_rounded, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '你好，$nickname',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '今天是 ${_dateText(DateTime.now())}，继续推进你的实习进度',
                  style: const TextStyle(
                    color: Color(0xFFDBE8FF),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: '退出登录',
          ),
        ],
      ),
    );
  }

  Widget _metricRow() {
    final pendingInterviews =
        _vm.interviews.where((item) => _toInt(item['status']) == 1).length;
    final pendingOffers =
        _vm.offers.where((item) => _toInt(item['status']) == 1).length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _metric(
              '可投岗位',
              _vm.jobs.length.toString(),
              const Color(0xFF2F6BFF),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _metric(
              '我的投递',
              _vm.applications.length.toString(),
              const Color(0xFF1F8A5A),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _metric(
              '待面试',
              pendingInterviews.toString(),
              const Color(0xFF8A3FFC),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _metric(
              '待Offer',
              pendingOffers.toString(),
              const Color(0xFFC46A00),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDDE7F7)),
      ),
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _logout() {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
      arguments: LoginRouteArgs(
        baseUrl: widget.args.baseUrl,
        role: AccountRole.student,
      ),
    );
  }

  void _showMessage(String text) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  Widget _badgeIcon(int count, IconData icon) {
    if (count <= 0) {
      return Icon(icon);
    }
    final text = count > 99 ? '99+' : '$count';
    return Badge(
      label: Text(text, style: const TextStyle(fontSize: 10)),
      backgroundColor: const Color(0xFFE53935),
      child: Icon(icon),
    );
  }

  int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }

  String _dateText(DateTime value) {
    return '${value.year}-${_two(value.month)}-${_two(value.day)}';
  }

  String _two(int value) => value.toString().padLeft(2, '0');
}
