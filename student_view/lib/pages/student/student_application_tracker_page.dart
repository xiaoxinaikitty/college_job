import 'package:flutter/material.dart';

import '../../viewmodels/student_home_view_model.dart';

class StudentApplicationTrackerPage extends StatelessWidget {
  const StudentApplicationTrackerPage({
    super.key,
    required this.vm,
    required this.onMessage,
  });

  final StudentHomeViewModel vm;
  final void Function(String text) onMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('投递流程追踪')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEFF4FF), Colors.white],
          ),
        ),
        child: AnimatedBuilder(
          animation: vm,
          builder: (_, __) {
            final stats = _buildStats(vm.applications);
            return RefreshIndicator(
              onRefresh: () async => _safeAction(() async {
                await vm.loadApplications();
              }),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  _summaryCard(stats),
                  const SizedBox(height: 12),
                  if (vm.applications.isEmpty)
                    const _EmptyBlock(text: '暂无投递记录')
                  else
                    ...vm.applications
                        .map((app) => _applicationCard(context, app)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _summaryCard(Map<int, int> stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('流程概览', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _metric('总投递', '${_sum(stats)}', const Color(0xFF0B5FFF)),
                _metric('沟通中', '${stats[3] ?? 0}', const Color(0xFF00A870)),
                _metric('面试中', '${stats[4] ?? 0}', const Color(0xFF2F6BFF)),
                _metric('Offer中', '${stats[5] ?? 0}', const Color(0xFF8A3FFC)),
                _metric('已录用', '${stats[6] ?? 0}', const Color(0xFF157347)),
                _metric('已结束', '${(stats[7] ?? 0) + (stats[8] ?? 0)}',
                    const Color(0xFFAA2B2B)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(String label, String value, Color color) {
    return Container(
      width: 104,
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

  Widget _applicationCard(BuildContext context, Map<String, dynamic> app) {
    final applicationId = _toInt(app['applicationId']);
    final status = _toInt(app['status']);
    final rejectReason = _text(app['rejectReason']);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        title: Row(
          children: [
            Expanded(
              child: Text(
                _text(app['applicationNo']),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            _statusTag(_statusLabel(status), _statusColor(status)),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('岗位ID: ${_text(app['jobId'])}'),
              Text('企业ID: ${_text(app['enterpriseId'])}'),
              Text('投递时间: ${_formatDateTime(app['submittedAt'])}'),
              Text('最近变更: ${_formatDateTime(app['lastActionAt'])}'),
              if (rejectReason != '-') Text('原因: $rejectReason'),
            ],
          ),
        ),
        trailing: TextButton(
          onPressed: applicationId == null
              ? null
              : () => _showTimeline(context, applicationId),
          child: const Text('流程'),
        ),
      ),
    );
  }

  Widget _statusTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _showTimeline(BuildContext context, int applicationId) async {
    await _safeAction(() async {
      final detail = await vm.applicationDetail(applicationId);
      final logs = _asMapList(detail['statusLogs']);
      if (!context.mounted) {
        return;
      }
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        builder: (_) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '流程日志 #$applicationId',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 12),
                if (logs.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text('暂无状态流转日志'),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (_, index) {
                        final log = logs[index];
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            '${_statusLabel(_toInt(log['fromStatus']))} -> ${_statusLabel(_toInt(log['toStatus']))}',
                          ),
                          subtitle: Text(
                            '${_formatDateTime(log['createdAt'])}  ${_text(log['note'])}',
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemCount: logs.length,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Map<int, int> _buildStats(List<Map<String, dynamic>> items) {
    final map = <int, int>{};
    for (final item in items) {
      final status = _toInt(item['status']);
      if (status == null) {
        continue;
      }
      map[status] = (map[status] ?? 0) + 1;
    }
    return map;
  }

  int _sum(Map<int, int> map) {
    var total = 0;
    for (final value in map.values) {
      total += value;
    }
    return total;
  }

  String _statusLabel(int? status) {
    switch (status) {
      case 1:
        return '已投递';
      case 2:
        return '已查看';
      case 3:
        return '沟通中';
      case 4:
        return '面试中';
      case 5:
        return 'Offer阶段';
      case 6:
        return '已录用';
      case 7:
        return '已淘汰';
      case 8:
        return '已撤回';
      default:
        return '未知';
    }
  }

  Color _statusColor(int? status) {
    switch (status) {
      case 3:
      case 4:
        return const Color(0xFF2F6BFF);
      case 5:
        return const Color(0xFF8A3FFC);
      case 6:
        return const Color(0xFF157347);
      case 7:
      case 8:
        return const Color(0xFFAA2B2B);
      default:
        return const Color(0xFF5B6575);
    }
  }

  Future<void> _safeAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      onMessage(e.toString());
    }
  }

  List<Map<String, dynamic>> _asMapList(dynamic value) {
    if (value is! List) {
      return <Map<String, dynamic>>[];
    }
    return value.map((item) => _asMap(item)).toList();
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), v));
    }
    return <String, dynamic>{};
  }

  String _text(dynamic value) {
    final text = value?.toString();
    if (text == null || text.trim().isEmpty || text == 'null') {
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

  String _formatDateTime(dynamic value) {
    final raw = _text(value);
    if (raw == '-') {
      return raw;
    }
    final dt = DateTime.tryParse(raw);
    if (dt == null) {
      return raw;
    }
    final local = dt.toLocal();
    return '${local.year}-${_two(local.month)}-${_two(local.day)} '
        '${_two(local.hour)}:${_two(local.minute)}';
  }
  String _two(int value) => value.toString().padLeft(2, '0');
}

class _EmptyBlock extends StatelessWidget {
  const _EmptyBlock({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined, size: 36, color: Color(0xFF95A3B8)),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(color: Color(0xFF6B778C))),
        ],
      ),
    );
  }
}
