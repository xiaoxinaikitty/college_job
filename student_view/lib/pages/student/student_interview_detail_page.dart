import 'package:flutter/material.dart';

import '../../viewmodels/student_home_view_model.dart';
import 'student_interview_confirm_page.dart';

class StudentInterviewDetailPage extends StatelessWidget {
  const StudentInterviewDetailPage({
    super.key,
    required this.vm,
    required this.interview,
    required this.onMessage,
  });

  final StudentHomeViewModel vm;
  final Map<String, dynamic> interview;
  final void Function(String text) onMessage;

  @override
  Widget build(BuildContext context) {
    final interviewId = _toInt(interview['id']);
    final status = _toInt(interview['status']);
    final canConfirm = interviewId != null && status == 1;

    return Scaffold(
      appBar: AppBar(title: const Text('面试详情')),
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
            final confirmState = interviewId == null
                ? null
                : vm.interviewConfirmState(interviewId);
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _overviewCard(),
                const SizedBox(height: 12),
                _scheduleCard(),
                const SizedBox(height: 12),
                _locationCard(),
                const SizedBox(height: 12),
                _confirmCard(confirmState),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: canConfirm
                      ? () =>
                          _openConfirmPage(context, interviewId, confirmState)
                      : null,
                  icon: const Icon(Icons.task_alt),
                  label: Text(canConfirm ? '去确认面试安排' : '当前状态不可确认'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _overviewCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('基础信息', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            _kv('面试ID', _text(interview['id'])),
            _kv('申请ID', _text(interview['applicationId'])),
            _kv('面试类型', _typeLabel(_toInt(interview['interviewType']))),
            _kv('面试状态', _statusLabel(_toInt(interview['status']))),
          ],
        ),
      ),
    );
  }

  Widget _scheduleCard() {
    final duration = _toInt(interview['durationMinutes']);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('时间安排', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            _kv('面试时间', _formatDateTime(interview['scheduledAt'])),
            _kv('预计时长', duration == null ? '-' : '${duration} 分钟'),
            _kv('备注', _text(interview['remark'])),
          ],
        ),
      ),
    );
  }

  Widget _locationCard() {
    final type = _toInt(interview['interviewType']);
    final isOnline = type == 1;
    final title = isOnline ? '线上链接' : '线下面试地点';
    final value = isOnline
        ? _text(interview['meetingLink'])
        : _text(interview['location']);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('面试方式', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            _kv('方式', _typeLabel(type)),
            _kv(title, value == '-' ? (isOnline ? '未提供链接' : '未填写地点') : value),
          ],
        ),
      ),
    );
  }

  Widget _confirmCard(Map<String, dynamic>? confirmState) {
    final action = _text(confirmState?['action']);
    final note = _text(confirmState?['note']);
    final expected = _formatDateTime(confirmState?['expectedRescheduleAt']);
    final submittedAt = _formatDateTime(confirmState?['submittedAt']);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('我的确认状态', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            if (confirmState == null)
              const Text('尚未提交确认操作')
            else ...[
              _kv('操作', _confirmActionLabel(action)),
              _kv('提交时间', submittedAt),
              if (action == 'reschedule') _kv('期望时间', expected),
              if (note != '-') _kv('说明', note),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openConfirmPage(
    BuildContext context,
    int? interviewId,
    Map<String, dynamic>? confirmState,
  ) async {
    if (interviewId == null) {
      return;
    }
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => StudentInterviewConfirmPage(
          vm: vm,
          interview: interview,
          initialAction: confirmState?['action']?.toString(),
          onMessage: onMessage,
        ),
      ),
    );
    if (changed == true) {
      onMessage('面试确认已提交');
    }
  }

  Widget _kv(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              key,
              style: const TextStyle(color: Color(0xFF697386), fontSize: 13),
            ),
          ),
          Expanded(child:   Text(value)),
        ],
      ),
    );
  }

  String _confirmActionLabel(String action) {
    switch (action) {
      case 'confirm':
        return '确认参加';
      case 'reschedule':
        return '申请改期';
      case 'decline':
        return '无法参加';
      default:
        return '-';
    }
  }

  String _typeLabel(int? type) {
    switch (type) {
      case 1:
        return '线上面试';
      case 2:
        return '线下面试';
      default:
        return '未知类型';
    }
  }

  String _statusLabel(int? status) {
    switch (status) {
      case 1:
        return '待面试';
      case 2:
        return '已完成';
      case 3:
        return '已取消';
      default:
        return '状态未知';
    }
  }

  String _formatDateTime(dynamic value) {
    final raw = _text(value);
    if (raw.isEmpty || raw == '-') {
      return '-';
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
}
