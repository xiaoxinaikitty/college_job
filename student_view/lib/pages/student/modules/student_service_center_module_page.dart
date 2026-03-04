import 'package:flutter/material.dart';

import '../../../viewmodels/student_home_view_model.dart';
import '../student_application_tracker_page.dart';
import '../student_feedback_center_page.dart';
import '../student_interviews_page.dart';
import '../student_offer_center_page.dart';

class StudentServiceCenterModulePage extends StatelessWidget {
  const StudentServiceCenterModulePage({
    super.key,
    required this.vm,
    required this.onMessage,
  });

  final StudentHomeViewModel vm;
  final void Function(String text) onMessage;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          vm.loadApplications(),
          vm.loadInterviews(),
          vm.loadOffers(),
          vm.loadReviews(),
          vm.loadReports(),
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
    final applying = vm.applications.where((item) {
      final status = _toInt(item['status']) ?? 0;
      return status >= 1 && status <= 5;
    }).length;
    final offersPending =
        vm.offers.where((item) => (_toInt(item['status']) ?? 0) == 1).length;
    final reportPending =
        vm.reports.where((item) => (_toInt(item['status']) ?? 0) != 3).length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('学生服务中心', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _metric('进行中流程', '$applying', const Color(0xFF2F6BFF)),
                _metric('待处理Offer', '$offersPending', const Color(0xFF8A3FFC)),
                _metric('待处理反馈', '$reportPending', const Color(0xFFAA2B2B)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(String label, String value, Color color) {
    return Container(
      width: 110,
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
        title: '流程追踪',
        subtitle: '查看投递流转与日志',
        icon: Icons.alt_route_rounded,
        color: const Color(0xFF2F6BFF),
        onTap: () => _openPage(
          context,
          StudentApplicationTrackerPage(vm: vm, onMessage: onMessage),
          reload: vm.loadApplications,
        ),
      ),
      _Entry(
        title: '面试中心',
        subtitle: '查看安排并确认',
        icon: Icons.event_note_rounded,
        color: const Color(0xFF0B5FFF),
        onTap: () => _openPage(
          context,
          StudentInterviewsPage(vm: vm, onMessage: onMessage),
          reload: vm.loadInterviews,
        ),
      ),
      _Entry(
        title: 'Offer中心',
        subtitle: '统一处理Offer',
        icon: Icons.mark_email_read_outlined,
        color: const Color(0xFF8A3FFC),
        onTap: () => _openPage(
          context,
          StudentOfferCenterPage(vm: vm, onMessage: onMessage),
          reload: () async {
            await vm.loadOffers();
            await vm.loadApplications();
          },
        ),
      ),
      _Entry(
        title: '反馈治理',
        subtitle: '评价与举报记录',
        icon: Icons.gavel_outlined,
        color: const Color(0xFFAA2B2B),
        onTap: () => _openPage(
          context,
          StudentFeedbackCenterPage(vm: vm, onMessage: onMessage),
          reload: () async {
            await vm.loadReviews();
            await vm.loadReports();
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
        childAspectRatio: 1.33,
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
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF5B6575),
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
            Text('1. 流程追踪 对齐 管理后台「流程监控」'),
            Text('2. 反馈治理 对齐 管理后台「评价管理 / 举报中心」'),
            Text('3. Offer中心 对齐 管理后台「投递阶段看板」'),
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
