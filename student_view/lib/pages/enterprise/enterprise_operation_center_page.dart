import 'package:flutter/material.dart';

import '../../viewmodels/enterprise_home_view_model.dart';

class EnterpriseOperationCenterPage extends StatelessWidget {
  const EnterpriseOperationCenterPage({
    super.key,
    required this.vm,
  });

  final EnterpriseHomeViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('运营看板')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEAF7EF), Colors.white],
          ),
        ),
        child: AnimatedBuilder(
          animation: vm,
          builder: (_, __) => RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                vm.loadProfile(),
                vm.loadJobs(),
                vm.loadApplications(),
                vm.loadInterviews(),
                vm.loadOffers(),
              ]);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _metricSection(),
                const SizedBox(height: 12),
                _pipelineSection(),
                const SizedBox(height: 12),
                _riskSection(),
                const SizedBox(height: 12),
                _alignmentSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _metricSection() {
    final totalJobs = vm.jobs.length;
    final onlineJobs =
        vm.jobs.where((item) => _toInt(item['status']) == 3).length;
    final pendingJobs =
        vm.jobs.where((item) => _toInt(item['status']) == 2).length;
    final rejectedJobs =
        vm.jobs.where((item) => _toInt(item['status']) == 4).length;
    final totalApps = vm.applications.length;
    final interviewing =
        vm.applications.where((item) => _toInt(item['status']) == 4).length;
    final offerStage =
        vm.applications.where((item) => _toInt(item['status']) == 5).length;
    final hired =
        vm.applications.where((item) => _toInt(item['status']) == 6).length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('核心指标', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _metric('岗位总数', '$totalJobs', const Color(0xFF11653F)),
                _metric('已上线', '$onlineJobs', const Color(0xFF157347)),
                _metric('待审核', '$pendingJobs', const Color(0xFF9B6A00)),
                _metric('已驳回', '$rejectedJobs', const Color(0xFFAA2B2B)),
                _metric('候选人数', '$totalApps', const Color(0xFF2F6BFF)),
                _metric('面试中', '$interviewing', const Color(0xFF2F6BFF)),
                _metric('Offer阶段', '$offerStage', const Color(0xFF8A3FFC)),
                _metric('已录用', '$hired', const Color(0xFF157347)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pipelineSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('流程分布', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            ..._statusRows(),
          ],
        ),
      ),
    );
  }

  List<Widget> _statusRows() {
    final total = vm.applications.length == 0 ? 1 : vm.applications.length;
    final rows = <_StatusRow>[
      _StatusRow('已投递', 1, const Color(0xFF5B6575)),
      _StatusRow('已查看', 2, const Color(0xFF5B6575)),
      _StatusRow('沟通中', 3, const Color(0xFF2F6BFF)),
      _StatusRow('面试中', 4, const Color(0xFF2F6BFF)),
      _StatusRow('Offer阶段', 5, const Color(0xFF8A3FFC)),
      _StatusRow('已录用', 6, const Color(0xFF157347)),
      _StatusRow('已淘汰', 7, const Color(0xFFAA2B2B)),
    ];
    return rows.map((item) {
      final count = vm.applications
          .where((element) => _toInt(element['status']) == item.status)
          .length;
      final ratio = count / total;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            SizedBox(
              width: 74,
              child: Text(
                item.label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF5B6575)),
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 10,
                  backgroundColor: const Color(0xFFE8EDF4),
                  valueColor: AlwaysStoppedAnimation(item.color),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 24,
              child: Text(
                '$count',
                textAlign: TextAlign.right,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _riskSection() {
    final certStatus = _toInt(vm.profile['certifiedStatus']) ?? 1;
    final statusLabel = _text(vm.profile['certifiedStatusLabel']);
    final riskLevel = certStatus == 3
        ? '低'
        : certStatus == 2
            ? '中'
            : '高';
    final riskColor = certStatus == 3
        ? const Color(0xFF157347)
        : certStatus == 2
            ? const Color(0xFF9B6A00)
            : const Color(0xFFAA2B2B);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('风险与审核', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: Text('企业认证状态: $statusLabel')),
                _riskTag('风险:$riskLevel', riskColor),
              ],
            ),
            const SizedBox(height: 8),
            Text(
                '待审核岗位: ${vm.jobs.where((item) => _toInt(item['status']) == 2).length}'),
            Text(
                '驳回岗位: ${vm.jobs.where((item) => _toInt(item['status']) == 4).length}'),
            Text(
                '已下线岗位: ${vm.jobs.where((item) => _toInt(item['status']) == 5).length}'),
          ],
        ),
      ),
    );
  }

  Widget _alignmentSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('与管理员模块对齐', style: TextStyle(fontWeight: FontWeight.w700)),
            SizedBox(height: 8),
            Text('1. 认证状态 对齐 管理后台「企业审核」'),
            Text('2. 岗位状态 对齐 管理后台「岗位审核」'),
            Text('3. 候选流程分布 对齐 管理后台「流程监控」'),
            Text('4. 风险提示 对齐 管理后台「治理中心」'),
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

  Widget _riskTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
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

  String _text(dynamic value) {
    final text = value?.toString();
    if (text == null || text.trim().isEmpty || text == 'null') {
      return '-';
    }
    return text;
  }
}

class _StatusRow {
  const _StatusRow(this.label, this.status, this.color);

  final String label;
  final int status;
  final Color color;
}
