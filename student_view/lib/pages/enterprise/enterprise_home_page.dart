import 'package:flutter/material.dart';

import '../../models/account_role.dart';
import '../../routes/app_routes.dart';
import '../../routes/route_args.dart';
import '../../viewmodels/enterprise_home_view_model.dart';
import 'modules/enterprise_candidates_module_page.dart';
import 'modules/enterprise_chats_module_page.dart';
import 'modules/enterprise_jobs_module_page.dart';
import 'modules/enterprise_profile_module_page.dart';

class EnterpriseHomePage extends StatefulWidget {
  const EnterpriseHomePage({
    super.key,
    required this.args,
  });

  final DashboardRouteArgs args;

  @override
  State<EnterpriseHomePage> createState() => _EnterpriseHomePageState();
}

class _EnterpriseHomePageState extends State<EnterpriseHomePage> {
  late final EnterpriseHomeViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = EnterpriseHomeViewModel(
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
            colors: [Color(0xFFEAF7EF), Colors.white],
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
                          EnterpriseJobsModulePage(
                            vm: _vm,
                            onMessage: _showMessage,
                          ),
                          EnterpriseCandidatesModulePage(
                            vm: _vm,
                            onMessage: _showMessage,
                          ),
                          EnterpriseChatsModulePage(
                            vm: _vm,
                            onMessage: _showMessage,
                          ),
                          EnterpriseProfileModulePage(
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
        destinations: const [
          NavigationDestination(icon: Icon(Icons.work_outline), label: '岗位'),
          NavigationDestination(
            icon: Icon(Icons.groups_2_outlined),
            label: '候选人',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            label: '沟通',
          ),
          NavigationDestination(
              icon: Icon(Icons.business_outlined), label: '企业'),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF128C53),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.business_center_rounded, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '企业工作台  ${widget.args.payload.nickname}',
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
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
      arguments: LoginRouteArgs(
        baseUrl: widget.args.baseUrl,
        role: AccountRole.enterprise,
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
}
