import 'package:flutter/material.dart';

import '../../../viewmodels/enterprise_home_view_model.dart';
import '../enterprise_interview_center_page.dart';
import '../enterprise_offer_center_page.dart';
import '../enterprise_operation_center_page.dart';

class EnterpriseOperationsModulePage extends StatelessWidget {
  const EnterpriseOperationsModulePage({
    super.key,
    required this.vm,
    required this.onMessage,
  });

  final EnterpriseHomeViewModel vm;
  final void Function(String text) onMessage;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          vm.loadApplications(),
          vm.loadInterviews(),
          vm.loadOffers(),
          vm.loadProfile(),
          vm.loadJobs(),
        ]);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        children: [
          _overviewCard(),
          const SizedBox(height: 12),
          _entryGrid(context),
          const SizedBox(height: 12),
          _adminAlignmentCard(),
        ],
      ),
    );
  }

  Widget _overviewCard() {
    final interviewPending = vm.interviews
        .where((item) => (_toInt(item['status']) ?? 0) == 1)
        .length;
    final offerPending =
        vm.offers.where((item) => (_toInt(item['status']) ?? 0) == 1).length;
    final candidatePending = vm.applications.where((item) {
      final status = _toInt(item['status']) ?? 0;
      return status >= 1 && status <= 3;
    }).length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('企业运营中心', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _metric('待推进候选人', '$candidatePending', const Color(0xFF2F6BFF)),
                _metric('待面试', '$interviewPending', const Color(0xFF128C53)),
                _metric('待处理Offer', '$offerPending', const Color(0xFF8A3FFC)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(String label, String value, Color color) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _entryGrid(BuildContext context) {
    final entries = [
      _Entry(
        title: '面试中心',
        subtitle: '安排与结果提交',
        icon: Icons.event_note_rounded,
        color: const Color(0xFF128C53),
        onTap: () => _openPage(
          context,
          EnterpriseInterviewCenterPage(vm: vm, onMessage: onMessage),
          reload: () async {
            await vm.loadInterviews();
            await vm.loadApplications();
          },
        ),
      ),
      _Entry(
        title: 'Offer中心',
        subtitle: '发放与跟踪',
        icon: Icons.mark_email_read_outlined,
        color: const Color(0xFF8A3FFC),
        onTap: () => _openPage(
          context,
          EnterpriseOfferCenterPage(vm: vm, onMessage: onMessage),
          reload: () async {
            await vm.loadOffers();
            await vm.loadApplications();
          },
        ),
      ),
      _Entry(
        title: '运营看板',
        subtitle: '指标与风险总览',
        icon: Icons.analytics_outlined,
        color: const Color(0xFF2F6BFF),
        onTap: () => _openPage(
          context,
          EnterpriseOperationCenterPage(vm: vm),
          reload: () async {
            await vm.loadProfile();
            await vm.loadJobs();
            await vm.loadApplications();
            await vm.loadInterviews();
            await vm.loadOffers();
          },
        ),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.38,
      ),
      itemBuilder: (_, index) {
        final entry = entries[index];
        return InkWell(
          onTap: entry.onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: entry.color.withOpacity(0.08),
              border: Border.all(color: entry.color.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(entry.icon, color: entry.color),
                const SizedBox(height: 8),
                Text(
                  entry.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.subtitle,
                  style: const TextStyle(
                    color: Color(0xFF5B6575),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _adminAlignmentCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('与管理员模块对齐', style: TextStyle(fontWeight: FontWeight.w700)),
            SizedBox(height: 8),
            Text('1. 面试中心 对齐 管理后台「流程监控」'),
            Text('2. Offer中心 对齐 管理后台「流程监控 / 用户管理」'),
            Text('3. 运营看板 对齐 管理后台「仪表盘 / 审核中心」'),
          ],
        ),
      ),
    );
  }

  Future<void> _openPage(
    BuildContext context,
    Widget page, {
    required Future<void> Function() reload,
  }) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    try {
      await reload();
    } catch (_) {
      // keep current page responsive even if reload fails
    }
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
}

class _Entry {
  const _Entry({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}
