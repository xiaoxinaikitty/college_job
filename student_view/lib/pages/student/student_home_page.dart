import 'package:flutter/material.dart';

import '../../models/account_role.dart';
import '../../routes/app_routes.dart';
import '../../routes/route_args.dart';
import '../../viewmodels/student_home_view_model.dart';
import 'modules/student_applications_module_page.dart';
import 'modules/student_chats_module_page.dart';
import 'modules/student_jobs_module_page.dart';
import 'modules/student_profile_module_page.dart';

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
            colors: [Color(0xFFEFF4FF), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _header(),
              Expanded(
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
                          StudentProfileModulePage(
                            vm: _vm,
                            onMessage: _showMessage,
                          ),
                        ],
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
          NavigationDestination(icon: Icon(Icons.person_outline), label: '我的'),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B5FFF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.school_rounded, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '学生主页  ${widget.args.payload.nickname}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
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
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
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
}
