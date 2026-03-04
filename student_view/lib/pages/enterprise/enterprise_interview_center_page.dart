import 'package:flutter/material.dart';

import '../../viewmodels/enterprise_home_view_model.dart';

class EnterpriseInterviewCenterPage extends StatefulWidget {
  const EnterpriseInterviewCenterPage({
    super.key,
    required this.vm,
    required this.onMessage,
  });

  final EnterpriseHomeViewModel vm;
  final void Function(String text) onMessage;

  @override
  State<EnterpriseInterviewCenterPage> createState() =>
      _EnterpriseInterviewCenterPageState();
}

class _EnterpriseInterviewCenterPageState
    extends State<EnterpriseInterviewCenterPage> {
  int? _statusFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('面试中心'),
        actions: [
          IconButton(
            onPressed: _openCreateInterview,
            icon: const Icon(Icons.add_circle_outline),
            tooltip: '安排面试',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEAF7EF), Colors.white],
          ),
        ),
        child: AnimatedBuilder(
          animation: widget.vm,
          builder: (_, __) {
            final interviews = _filteredInterviews(widget.vm.interviews);
            return RefreshIndicator(
              onRefresh: () async => _safeAction(widget.vm.loadInterviews),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  _summaryAndFilter(widget.vm.interviews),
                  const SizedBox(height: 12),
                  if (interviews.isEmpty)
                    const _EmptyBlock(text: '暂无面试记录')
                  else
                    ...interviews.map(_interviewCard),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _summaryAndFilter(List<Map<String, dynamic>> interviews) {
    final pending =
        interviews.where((item) => _toInt(item['status']) == 1).length;
    final completed =
        interviews.where((item) => _toInt(item['status']) == 3).length;
    final cancelled =
        interviews.where((item) => _toInt(item['status']) == 4).length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _metric('待面试', '$pending', const Color(0xFF2F6BFF)),
                _metric('已完成', '$completed', const Color(0xFF157347)),
                _metric('已取消', '$cancelled', const Color(0xFFAA2B2B)),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                _filterChip('全部', null),
                _filterChip('待面试', 1),
                _filterChip('已完成', 3),
                _filterChip('已取消', 4),
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

  Widget _filterChip(String text, int? value) {
    return ChoiceChip(
      label: Text(text),
      selected: _statusFilter == value,
      onSelected: (_) => setState(() => _statusFilter = value),
    );
  }

  Widget _interviewCard(Map<String, dynamic> item) {
    final interviewId = _toInt(item['interviewId']);
    final status = _toInt(item['status']);
    final canResult = interviewId != null && status != 4;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${_text(item['studentNickname'])} · ${_text(item['interviewTypeLabel'])}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                _statusTag(_text(item['statusLabel']), _statusColor(status)),
              ],
            ),
            const SizedBox(height: 8),
            Text('申请ID: ${_text(item['applicationId'])}'),
            Text('面试时间: ${_formatDateTime(item['scheduledAt'])}'),
            Text('时长: ${_text(item['durationMinutes'])} 分钟'),
            if (_text(item['confirmActionLabel']) != '-')
              Text('学生反馈: ${_text(item['confirmActionLabel'])}'),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed:
                  canResult ? () => _openResultDialog(interviewId!) : null,
              child: const Text('填写结果'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusTag(String text, Color color) {
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

  Future<void> _openCreateInterview() async {
    final candidates = widget.vm.applications.where((item) {
      final status = _toInt(item['status']) ?? 0;
      return status >= 1 && status <= 5;
    }).toList();
    if (candidates.isEmpty) {
      widget.onMessage('当前无可安排面试的候选人');
      return;
    }
    var selectedIndex = 0;
    var type = 1;
    DateTime? scheduledAt;
    final durationCtl = TextEditingController(text: '30');
    final meetingCtl = TextEditingController();
    final locationCtl = TextEditingController();
    final remarkCtl = TextEditingController();
    final controllers = <TextEditingController>[
      durationCtl,
      meetingCtl,
      locationCtl,
      remarkCtl,
    ];

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (_, setLocal) {
          return AlertDialog(
            title: const Text('安排面试'),
            content: SizedBox(
              width: 440,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      value: selectedIndex,
                      decoration: const InputDecoration(labelText: '选择候选人'),
                      items: [
                        for (var i = 0; i < candidates.length; i++)
                          DropdownMenuItem<int>(
                            value: i,
                            child: Text(
                              '${_text(candidates[i]['studentNickname'])} · ${_text(candidates[i]['jobTitle'])}',
                            ),
                          ),
                      ],
                      onChanged: (value) =>
                          setLocal(() => selectedIndex = value ?? 0),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: type,
                      decoration: const InputDecoration(labelText: '面试类型'),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('线上面试')),
                        DropdownMenuItem(value: 2, child: Text('线下面试')),
                      ],
                      onChanged: (value) => setLocal(() => type = value ?? 1),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            scheduledAt == null
                                ? '请选择面试时间'
                                : _formatDateTime(
                                    scheduledAt!.toIso8601String()),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final picked = await _pickDateTime();
                            if (picked != null) {
                              setLocal(() => scheduledAt = picked);
                            }
                          },
                          child: const Text('选择'),
                        ),
                      ],
                    ),
                    TextField(
                      controller: durationCtl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: '时长(分钟)'),
                    ),
                    const SizedBox(height: 8),
                    if (type == 1)
                      TextField(
                        controller: meetingCtl,
                        decoration: const InputDecoration(labelText: '会议链接'),
                      )
                    else
                      TextField(
                        controller: locationCtl,
                        decoration: const InputDecoration(labelText: '面试地点'),
                      ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: remarkCtl,
                      minLines: 2,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: '备注'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  Navigator.of(dialogContext).pop(false);
                },
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () async {
                  final appId =
                      _toInt(candidates[selectedIndex]['applicationId']);
                  final duration = int.tryParse(durationCtl.text.trim());
                  if (appId == null ||
                      scheduledAt == null ||
                      duration == null) {
                    widget.onMessage('请填写完整面试信息');
                    return;
                  }
                  try {
                    await widget.vm.createInterview({
                      'applicationId': appId,
                      'interviewType': type,
                      'scheduledAt': scheduledAt!.toIso8601String(),
                      'durationMinutes': duration,
                      'meetingLink':
                          type == 1 ? _nullable(meetingCtl.text) : null,
                      'location':
                          type == 2 ? _nullable(locationCtl.text) : null,
                      'remark': _nullable(remarkCtl.text),
                    });
                    if (dialogContext.mounted) {
                      FocusManager.instance.primaryFocus?.unfocus();
                      Navigator.of(dialogContext).pop(true);
                    }
                  } catch (e) {
                    widget.onMessage(e.toString());
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF128C53),
                ),
                child: const Text('确认'),
              ),
            ],
          );
        },
      ),
    );

    _disposeControllersSafely(controllers);

    if (saved == true) {
      widget.onMessage('面试安排成功');
    }
  }

  Future<void> _openResultDialog(int interviewId) async {
    var result = 'pass';
    final noteCtl = TextEditingController();
    final controllers = <TextEditingController>[noteCtl];
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (_, setLocal) {
          return AlertDialog(
            title: const Text('填写面试结果'),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: result,
                    decoration: const InputDecoration(labelText: '结果'),
                    items: const [
                      DropdownMenuItem(value: 'pass', child: Text('通过')),
                      DropdownMenuItem(value: 'hold', child: Text('待定')),
                      DropdownMenuItem(value: 'fail', child: Text('未通过')),
                    ],
                    onChanged: (value) =>
                        setLocal(() => result = value ?? 'pass'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: noteCtl,
                    minLines: 2,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: '备注'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  Navigator.of(dialogContext).pop(false);
                },
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () async {
                  try {
                    await widget.vm.submitInterviewResult(
                      interviewId: interviewId,
                      result: result,
                      note: _nullable(noteCtl.text),
                    );
                    if (dialogContext.mounted) {
                      FocusManager.instance.primaryFocus?.unfocus();
                      Navigator.of(dialogContext).pop(true);
                    }
                  } catch (e) {
                    widget.onMessage(e.toString());
                  }
                },
                child: const Text('提交'),
              ),
            ],
          );
        },
      ),
    );
    _disposeControllersSafely(controllers);
    if (saved == true) {
      widget.onMessage('面试结果提交成功');
    }
  }

  void _disposeControllersSafely(List<TextEditingController> controllers) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 320), () {
        for (final controller in controllers) {
          controller.dispose();
        }
      });
    });
  }

  List<Map<String, dynamic>> _filteredInterviews(
      List<Map<String, dynamic>> source) {
    if (_statusFilter == null) {
      return source;
    }
    return source
        .where((item) => (_toInt(item['status']) ?? -1) == _statusFilter)
        .toList();
  }

  Future<DateTime?> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) {
      return null;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
    );
    if (time == null || !mounted) {
      return null;
    }
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _safeAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      widget.onMessage(e.toString());
    }
  }

  String? _nullable(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  Color _statusColor(int? status) {
    switch (status) {
      case 1:
      case 2:
        return const Color(0xFF2F6BFF);
      case 3:
        return const Color(0xFF157347);
      case 4:
        return const Color(0xFFAA2B2B);
      default:
        return const Color(0xFF5B6575);
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

  String _text(dynamic value) {
    final text = value?.toString();
    if (text == null || text.trim().isEmpty || text == 'null') {
      return '-';
    }
    return text;
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
          const Icon(Icons.event_busy_outlined,
              size: 36, color: Color(0xFF95A3B8)),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(color: Color(0xFF6B778C))),
        ],
      ),
    );
  }
}
