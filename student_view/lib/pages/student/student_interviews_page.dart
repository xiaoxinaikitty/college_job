import 'package:flutter/material.dart';

import '../../viewmodels/student_home_view_model.dart';
import 'student_interview_detail_page.dart';

class StudentInterviewsPage extends StatelessWidget {
  const StudentInterviewsPage({
    super.key,
    required this.vm,
    required this.onMessage,
  });

  final StudentHomeViewModel vm;
  final void Function(String text) onMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('面试安排')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEFF4FF), Colors.white],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: vm,
            builder: (_, __) {
              return RefreshIndicator(
                onRefresh: () => _runAction(vm.loadInterviews),
                child: vm.interviews.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 140),
                          Icon(
                            Icons.event_busy_outlined,
                            size: 44,
                            color: Color(0xFF8F9BB3),
                          ),
                          SizedBox(height: 10),
                          Center(child: Text('暂无面试安排')),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        itemCount: vm.interviews.length,
                        itemBuilder: (_, index) {
                          final interview = vm.interviews[index];
                          return _interviewCard(context, interview);
                        },
                      ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _interviewCard(BuildContext context, Map<String, dynamic> interview) {
    final interviewId = _toInt(interview['id']);
    final type = _toInt(interview['interviewType']);
    final status = _toInt(interview['status']);
    final timeText = _formatDateTime(interview['scheduledAt']);
    final duration = _toInt(interview['durationMinutes']);
    final meetingLink = _text(interview['meetingLink']);
    final location = _text(interview['location']);
    final remark = _text(interview['remark']);
    final applicationId = _text(interview['applicationId']);
    final isOnline = type == 1;
    final confirmAction = interviewId == null
        ? null
        : vm.interviewConfirmState(interviewId)?['action']?.toString();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openInterviewDetail(context, interview),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _pill(
                    _typeLabel(type),
                    const Color(0xFF0B5FFF),
                    const Color(0xFFE8F0FF),
                  ),
                  const SizedBox(width: 8),
                  _pill(
                    _statusLabel(status),
                    _statusColor(status),
                    _statusBackground(status),
                  ),
                  if (confirmAction != null) ...[
                    const SizedBox(width: 8),
                    _pill(
                      _confirmActionLabel(confirmAction),
                      const Color(0xFF1D7A34),
                      const Color(0xFFE3F7E8),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    '申请ID: $applicationId',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF637083),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.schedule_outlined, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '$timeText${duration == null ? '' : '  ·  ${duration}分钟'}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF90A0B7)),
                ],
              ),
              const SizedBox(height: 6),
              if (isOnline)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.videocam_outlined, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        meetingLink.isEmpty ? '未提供线上会议链接' : meetingLink,
                        style: const TextStyle(color: Color(0xFF3C4758)),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        location.isEmpty ? '未填写面试地点' : location,
                        style: const TextStyle(color: Color(0xFF3C4758)),
                      ),
                    ),
                  ],
                ),
              if (remark.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '备注: $remark',
                  style:
                      const TextStyle(fontSize: 13, color: Color(0xFF5B6575)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openInterviewDetail(
    BuildContext context,
    Map<String, dynamic> interview,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentInterviewDetailPage(
            vm: vm, interview: interview, onMessage: onMessage),
      ),
    );
  }

  Widget _pill(String text, Color foreground, Color background) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _runAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      onMessage(e.toString());
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

  String _confirmActionLabel(String action) {
    switch (action) {
      case 'confirm':
        return '已确认';
      case 'reschedule':
        return '已申请改期';
      case 'decline':
        return '已反馈无法参加';
      default:
        return '已提交';
    }
  }

  Color _statusColor(int? status) {
    switch (status) {
      case 1:
        return const Color(0xFFB26A00);
      case 2:
        return const Color(0xFF1D7A34);
      case 3:
        return const Color(0xFFAA2B2B);
      default:
        return const Color(0xFF5B6575);
    }
  }

  Color _statusBackground(int? status) {
    switch (status) {
      case 1:
        return const Color(0xFFFFF2DB);
      case 2:
        return const Color(0xFFE3F7E8);
      case 3:
        return const Color(0xFFFFE5E5);
      default:
        return const Color(0xFFEAEFF5);
    }
  }

  String _formatDateTime(dynamic value) {
    final raw = _text(value);
    if (raw.isEmpty) {
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

  String _text(dynamic value) => value?.toString() ?? '';

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
