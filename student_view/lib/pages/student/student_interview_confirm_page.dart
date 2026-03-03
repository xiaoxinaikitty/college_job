import 'package:flutter/material.dart';

import '../../viewmodels/student_home_view_model.dart';

class StudentInterviewConfirmPage extends StatefulWidget {
  const StudentInterviewConfirmPage({
    super.key,
    required this.vm,
    required this.interview,
    required this.onMessage,
    this.initialAction,
  });

  final StudentHomeViewModel vm;
  final Map<String, dynamic> interview;
  final void Function(String text) onMessage;
  final String? initialAction;

  @override
  State<StudentInterviewConfirmPage> createState() =>
      _StudentInterviewConfirmPageState();
}

class _StudentInterviewConfirmPageState
    extends State<StudentInterviewConfirmPage> {
  late String _action;
  final TextEditingController _noteCtl = TextEditingController();
  DateTime? _expectedAt;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _action = _normalizeAction(widget.initialAction);
  }

  @override
  void dispose() {
    _noteCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final interviewId = _toInt(widget.interview['id']);
    return Scaffold(
      appBar: AppBar(title: const Text('面试确认操作')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _topCard(interviewId),
          const SizedBox(height: 12),
          _actionCard(),
          const SizedBox(height: 12),
          _noteCard(),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: (_submitting || interviewId == null)
                ? null
                : () => _submit(interviewId),
            icon: _submitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_circle_outline),
            label: const Text('提交确认'),
          ),
          const SizedBox(height: 8),
          const Text(
            '提示：当前为学生端确认页面，后续可直接对接企业端确认接口。',
            style: TextStyle(fontSize: 12, color: Color(0xFF6D7684)),
          ),
        ],
      ),
    );
  }

  Widget _topCard(int? interviewId) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('当前面试', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('面试ID：${_text(interviewId)}'),
            Text('申请ID：${_text(widget.interview['applicationId'])}'),
            Text('安排时间：${_formatDateTime(widget.interview['scheduledAt'])}'),
          ],
        ),
      ),
    );
  }

  Widget _actionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('请选择操作', style: TextStyle(fontWeight: FontWeight.w700)),
            RadioListTile<String>(
              value: 'confirm',
              groupValue: _action,
              onChanged: (value) =>
                  setState(() => _action = value ?? 'confirm'),
              title: const Text('确认参加'),
              subtitle: const Text('按当前时间正常参加面试'),
            ),
            RadioListTile<String>(
              value: 'reschedule',
              groupValue: _action,
              onChanged: (value) =>
                  setState(() => _action = value ?? 'reschedule'),
              title: const Text('申请改期'),
              subtitle: const Text('填写期望面试时间，等待企业确认'),
            ),
            RadioListTile<String>(
              value: 'decline',
              groupValue: _action,
              onChanged: (value) =>
                  setState(() => _action = value ?? 'decline'),
              title: const Text('无法参加'),
              subtitle: const Text('提交原因并结束本次面试安排'),
            ),
            if (_action == 'reschedule') ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _expectedAt == null
                          ? '请选择期望时间'
                          : '期望时间：${_formatDateTime(_expectedAt!.toIso8601String())}',
                    ),
                  ),
                  TextButton(
                    onPressed: _pickExpectedTime,
                    child: const Text('选择时间'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _noteCard() {
    String hint = '可选补充说明';
    if (_action == 'reschedule') {
      hint = '请填写改期原因（可选）';
    } else if (_action == 'decline') {
      hint = '请填写无法参加原因（必填）';
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: TextField(
          controller: _noteCtl,
          minLines: 3,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: '说明',
            hintText: hint,
          ),
        ),
      ),
    );
  }

  Future<void> _pickExpectedTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _expectedAt ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) {
      return;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_expectedAt ?? now),
    );
    if (time == null) {
      return;
    }
    setState(() {
      _expectedAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _submit(int interviewId) async {
    final note = _noteCtl.text.trim();
    if (_action == 'reschedule' && _expectedAt == null) {
      widget.onMessage('请先选择期望面试时间');
      return;
    }
    if (_action == 'decline' && note.isEmpty) {
      widget.onMessage('请填写无法参加原因');
      return;
    }

    setState(() => _submitting = true);
    try {
      await widget.vm.submitInterviewConfirmation(
        interviewId: interviewId,
        action: _action,
        note: note.isEmpty ? null : note,
        expectedRescheduleAt: _expectedAt,
      );
      if (!mounted) {
        return;
      }
      Navigator.pop(context, true);
    } catch (e) {
      widget.onMessage(e.toString());
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  String _normalizeAction(String? raw) {
    final value = raw?.trim().toLowerCase() ?? '';
    if (value == 'reschedule' || value == 'decline' || value == 'confirm') {
      return value;
    }
    return 'confirm';
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
    final local =  dt.toLocal();
    return '${local.year}-${_two(local.month)}-${_two(local.day)} '
        '${_two(local.hour)}:${_two(local.minute)}';
  }

  String _text(dynamic value) => value?.toString() ?? '-';

  String _two(int value) => value.toString().padLeft(2, '0');

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
