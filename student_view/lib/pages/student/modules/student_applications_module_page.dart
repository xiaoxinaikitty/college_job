import 'package:flutter/material.dart';

import '../../../viewmodels/student_home_view_model.dart';

class StudentApplicationsModulePage extends StatelessWidget {
  const StudentApplicationsModulePage({
    super.key,
    required this.vm,
    required this.onMessage,
  });

  final StudentHomeViewModel vm;
  final void Function(String text) onMessage;

  @override
  Widget build(BuildContext context) {
    final total = vm.applications.length;
    final interviewing =
        vm.applications.where((item) => _toInt(item['status']) == 4).length;
    final offer =
        vm.applications.where((item) => _toInt(item['status']) == 5).length;
    return RefreshIndicator(
      onRefresh: vm.loadApplications,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(child: _metric('总投递', '$total')),
                  Expanded(child: _metric('面试中', '$interviewing')),
                  Expanded(child: _metric('Offer阶段', '$offer')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (vm.applications.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 100),
              child: Center(child: Text('暂无投递记录')),
            )
          else
            ...vm.applications.map((app) {
              final applicationId = _toInt(app['applicationId']);
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _toText(app['jobTitle']) == '-'
                                  ? '投递单号 ${_toText(app['applicationNo'])}'
                                  : _toText(app['jobTitle']),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          _statusTag(_toText(app['statusLabel'])),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('投递编号：${_toText(app['applicationNo'])}'),
                      Text('企业：${_toText(app['enterpriseName'])}'),
                      Text('更新时间：${_toText(app['lastActionAt'])}'),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: applicationId == null
                            ? null
                            : () => _showStatusLogs(context, applicationId),
                        child: const Text('查看流程日志'),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E40AF),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _statusTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF1E40AF),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Future<void> _showStatusLogs(BuildContext context, int applicationId) async {
    try {
      final data = await vm.applicationDetail(applicationId);
      final logs = (data['statusLogs'] as List<dynamic>? ?? [])
          .map((e) => e is Map<String, dynamic>
              ? e
              : (e as Map).map((k, v) => MapEntry(k.toString(), v)))
          .toList();
      if (!context.mounted) {
        return;
      }
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('状态流转日志'),
          content: SizedBox(
            width: double.maxFinite,
            child: logs.isEmpty
                ? const Text('暂无日志')
                : ListView.separated(
                    shrinkWrap: true,
                    itemBuilder: (_, index) {
                      final log = logs[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '${_toText(log['fromStatus'])} -> ${_toText(log['toStatus'])}',
                        ),
                        subtitle: Text(_toText(log['note'])),
                      );
                    },
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemCount: logs.length,
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('关闭'),
            ),
          ],
        ),
      );
    } catch (e) {
      onMessage(e.toString());
    }
  }

  String _toText(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text == 'null') {
      return '-';
    }
    return text;
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
