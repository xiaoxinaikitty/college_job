import 'package:flutter/material.dart';

import '../../../viewmodels/enterprise_home_view_model.dart';

class EnterpriseCandidatesModulePage extends StatefulWidget {
  const EnterpriseCandidatesModulePage({
    super.key,
    required this.vm,
    required this.onMessage,
  });

  final EnterpriseHomeViewModel vm;
  final void Function(String text) onMessage;

  @override
  State<EnterpriseCandidatesModulePage> createState() =>
      _EnterpriseCandidatesModulePageState();
}

class _EnterpriseCandidatesModulePageState
    extends State<EnterpriseCandidatesModulePage> {
  int? _statusFilter;
  int? _jobIdFilter;

  static const List<MapEntry<int?, String>> _statusOptions = [
    MapEntry(null, '全部'),
    MapEntry(1, '已投递'),
    MapEntry(2, '已查看'),
    MapEntry(3, '沟通中'),
    MapEntry(4, '面试中'),
    MapEntry(5, 'Offer阶段'),
    MapEntry(6, '已录用'),
    MapEntry(7, '已淘汰'),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 6),
            child: TabBar(
              tabs: [
                Tab(text: '候选人'),
                Tab(text: '面试'),
                Tab(text: 'Offer'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _candidateTab(),
                _interviewTab(),
                _offerTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _candidateTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Column(
            children: [
              SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _statusOptions.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(entry.value),
                        selected: _statusFilter == entry.key,
                        onSelected: (_) => _setStatusFilter(entry.key),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int?>(
                      value: _jobIdFilter,
                      decoration: const InputDecoration(
                        isDense: true,
                        labelText: '按岗位筛选',
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('全部岗位'),
                        ),
                        ...widget.vm.jobs.map((job) {
                          final id = _toInt(job['jobId']);
                          return DropdownMenuItem<int?>(
                            value: id,
                            child: Text(_text(job['title'])),
                          );
                        }),
                      ],
                      onChanged: _setJobFilter,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonal(
                    onPressed: _resetFilters,
                    child: const Text('重置'),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => widget.vm.loadApplications(
              status: _statusFilter,
              jobId: _jobIdFilter,
            ),
            child: widget.vm.applications.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 120),
                      Center(child: Text('暂无候选人数据')),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: widget.vm.applications.length,
                    itemBuilder: (_, index) {
                      final app = widget.vm.applications[index];
                      final applicationId = _toInt(app['applicationId']);
                      final hasOffer = _toBool(app['hasOffer']);
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
                                      _text(app['studentNickname']),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  _statusTag(_text(app['statusLabel'])),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text('岗位: ${_text(app['jobTitle'])}'),
                              Text('投递号: ${_text(app['applicationNo'])}'),
                              Text(
                                  '更新时间: ${_formatDateTime(app['lastActionAt'])}'),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  OutlinedButton(
                                    onPressed: applicationId == null
                                        ? null
                                        : () => _showApplicationDetail(
                                            applicationId!),
                                    child: const Text('详情'),
                                  ),
                                  FilledButton.tonal(
                                    onPressed: applicationId == null
                                        ? null
                                        : () =>
                                            _openStatusDialog(applicationId!),
                                    child: const Text('状态流转'),
                                  ),
                                  FilledButton.tonal(
                                    onPressed: applicationId == null
                                        ? null
                                        : () => _openInterviewDialog(
                                            applicationId!),
                                    child: const Text('安排面试'),
                                  ),
                                  FilledButton.tonal(
                                    onPressed: (applicationId == null ||
                                            hasOffer)
                                        ? null
                                        : () =>
                                            _openOfferDialog(applicationId!),
                                    child:
                                        Text(hasOffer ? '已发Offer' : '发Offer'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _interviewTab() {
    return RefreshIndicator(
      onRefresh: widget.vm.loadInterviews,
      child: widget.vm.interviews.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 120),
                Center(child: Text('暂无面试安排')),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: widget.vm.interviews.length,
              itemBuilder: (_, index) {
                final item = widget.vm.interviews[index];
                final interviewId = _toInt(item['interviewId']);
                final status = _toInt(item['status']);
                final canSubmit =
                    interviewId != null && status != 3 && status != 4;
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(
                      '${_text(item['studentNickname'])} · ${_text(item['interviewTypeLabel'])}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '时间: ${_formatDateTime(item['scheduledAt'])}\n'
                      '确认: ${_text(item['confirmActionLabel'])}',
                    ),
                    isThreeLine: true,
                    trailing: FilledButton.tonal(
                      onPressed: canSubmit
                          ? () => _openInterviewResultDialog(interviewId!)
                          : null,
                      child: const Text('填结果'),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _offerTab() {
    return RefreshIndicator(
      onRefresh: widget.vm.loadOffers,
      child: widget.vm.offers.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 120),
                Center(child: Text('暂无Offer记录')),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: widget.vm.offers.length,
              itemBuilder: (_, index) {
                final offer = widget.vm.offers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(
                      '${_text(offer['studentNickname'])} · ${_text(offer['jobTitle'])}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '状态: ${_text(offer['statusLabel'])}\n'
                      '有效期: ${_formatDateTime(offer['expiresAt'])}',
                    ),
                    isThreeLine: true,
                    trailing: Text(_text(offer['offerNo'])),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _showApplicationDetail(int applicationId) async {
    try {
      final data = await widget.vm.applicationDetail(applicationId);
      final app = _asMap(data['application']);
      final logs = _asMapList(data['statusLogs']);
      if (!mounted) {
        return;
      }
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('候选人详情'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('学生: ${_text(app['studentNickname'])}'),
                  Text('岗位: ${_text(app['jobTitle'])}'),
                  Text('状态: ${_text(app['statusLabel'])}'),
                  const SizedBox(height: 8),
                  const Text('状态日志',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  if (logs.isEmpty) const Text('暂无'),
                  ...logs.map((log) => Text(
                        '${_text(log['fromStatus'])} -> ${_text(log['toStatus'])} '
                        '${_text(log['note'])}',
                      )),
                ],
              ),
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
      widget.onMessage(e.toString());
    }
  }

  Future<void> _openStatusDialog(int applicationId) async {
    int toStatus = 2;
    final rejectCtl = TextEditingController();
    final noteCtl = TextEditingController();
    final controllers = <TextEditingController>[rejectCtl, noteCtl];
    if (!mounted) {
      _disposeControllersSafely(controllers);
      return;
    }
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, setLocal) {
        return AlertDialog(
          title: const Text('更新候选人状态'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: toStatus,
                  items: const [
                    DropdownMenuItem(value: 2, child: Text('已查看')),
                    DropdownMenuItem(value: 3, child: Text('沟通中')),
                    DropdownMenuItem(value: 4, child: Text('面试中')),
                    DropdownMenuItem(value: 5, child: Text('Offer阶段')),
                    DropdownMenuItem(value: 6, child: Text('已录用')),
                    DropdownMenuItem(value: 7, child: Text('已淘汰')),
                  ],
                  onChanged: (value) => setLocal(() => toStatus = value ?? 2),
                  decoration: const InputDecoration(labelText: '目标状态'),
                ),
                if (toStatus == 7)
                  TextField(
                    controller: rejectCtl,
                    decoration: const InputDecoration(labelText: '淘汰原因*'),
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
                Navigator.pop(ctx);
              },
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () async {
                if (toStatus == 7 && rejectCtl.text.trim().isEmpty) {
                  widget.onMessage('淘汰时必须填写原因');
                  return;
                }
                try {
                  await widget.vm.updateApplicationStatus(
                    applicationId: applicationId,
                    toStatus: toStatus,
                    rejectReason: _nullable(rejectCtl.text),
                    note: _nullable(noteCtl.text),
                  );
                  if (ctx.mounted) {
                    FocusManager.instance.primaryFocus?.unfocus();
                    Navigator.pop(ctx, true);
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
      }),
    );
    _disposeControllersSafely(controllers);
    if (saved == true) {
      widget.onMessage('候选人状态更新成功');
    }
  }

  Future<void> _openInterviewDialog(int applicationId) async {
    int type = 1;
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
    if (!mounted) {
      _disposeControllersSafely(controllers);
      return;
    }
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, setLocal) {
        return AlertDialog(
          title: const Text('安排面试'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: type,
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('线上面试')),
                      DropdownMenuItem(value: 2, child: Text('线下面试')),
                    ],
                    onChanged: (value) => setLocal(() => type = value ?? 1),
                    decoration: const InputDecoration(labelText: '面试类型'),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          scheduledAt == null
                              ? '请选择面试时间'
                              : _formatDateTime(scheduledAt!.toIso8601String()),
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
                Navigator.pop(ctx);
              },
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () async {
                final duration = int.tryParse(durationCtl.text.trim());
                if (scheduledAt == null || duration == null || duration <= 0) {
                  widget.onMessage('请填写完整面试信息');
                  return;
                }
                try {
                  await widget.vm.createInterview({
                    'applicationId': applicationId,
                    'interviewType': type,
                    'scheduledAt': scheduledAt!.toIso8601String(),
                    'durationMinutes': duration,
                    'meetingLink':
                        type == 1 ? _nullable(meetingCtl.text) : null,
                    'location': type == 2 ? _nullable(locationCtl.text) : null,
                    'remark': _nullable(remarkCtl.text),
                  });
                  if (ctx.mounted) {
                    FocusManager.instance.primaryFocus?.unfocus();
                    Navigator.pop(ctx, true);
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
      }),
    );
    _disposeControllersSafely(controllers);
    if (saved == true) {
      widget.onMessage('面试安排成功');
    }
  }

  Future<void> _openOfferDialog(int applicationId) async {
    final minCtl = TextEditingController();
    final maxCtl = TextEditingController();
    final termCtl = TextEditingController();
    final controllers = <TextEditingController>[minCtl, maxCtl, termCtl];
    if (!mounted) {
      _disposeControllersSafely(controllers);
      return;
    }
    DateTime? startDate;
    DateTime? endDate;
    DateTime? expireAt;
    final payload = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, setLocal) {
        return AlertDialog(
          title: const Text('发放Offer'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: minCtl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: '最低薪资'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: maxCtl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: '最高薪资'),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: Text('开始: ${_date(startDate)}')),
                      TextButton(
                        onPressed: () async {
                          final picked = await _pickDate();
                          if (picked != null) {
                            setLocal(() => startDate = picked);
                          }
                        },
                        child: const Text('选择'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: Text('结束: ${_date(endDate)}')),
                      TextButton(
                        onPressed: () async {
                          final picked = await _pickDate();
                          if (picked != null) {
                            setLocal(() => endDate = picked);
                          }
                        },
                        child: const Text('选择'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '截止: ${expireAt == null ? '-' : _formatDateTime(expireAt!.toIso8601String())}',
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final picked = await _pickDateTime();
                          if (picked != null) {
                            setLocal(() => expireAt = picked);
                          }
                        },
                        child: const Text('选择'),
                      ),
                    ],
                  ),
                  TextField(
                    controller: termCtl,
                    minLines: 2,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Offer条款'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus();
                Navigator.pop(ctx);
              },
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus();
                Navigator.pop(ctx, <String, dynamic>{
                  'applicationId': applicationId,
                  'salaryMin': double.tryParse(minCtl.text.trim()),
                  'salaryMax': double.tryParse(maxCtl.text.trim()),
                  'internshipStartDate':
                      startDate == null ? null : _date(startDate),
                  'internshipEndDate': endDate == null ? null : _date(endDate),
                  'termsText': _nullable(termCtl.text),
                  'expiresAt': expireAt?.toIso8601String(),
                });
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF128C53),
              ),
              child: const Text('发放'),
            ),
          ],
        );
      }),
    );
    _disposeControllersSafely(controllers);

    if (payload == null) {
      return;
    }

    try {
      await widget.vm.createOffer(payload);
      widget.onMessage('Offer发放成功');
    } catch (e) {
      widget.onMessage(e.toString());
    }
  }

  Future<void> _openInterviewResultDialog(int interviewId) async {
    String result = 'pass';
    final noteCtl = TextEditingController();
    final controllers = <TextEditingController>[noteCtl];
    if (!mounted) {
      _disposeControllersSafely(controllers);
      return;
    }
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, setLocal) {
        return AlertDialog(
          title: const Text('填写面试结果'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: result,
                  items: const [
                    DropdownMenuItem(value: 'pass', child: Text('通过')),
                    DropdownMenuItem(value: 'hold', child: Text('待定')),
                    DropdownMenuItem(value: 'fail', child: Text('未通过')),
                  ],
                  onChanged: (value) =>
                      setLocal(() => result = value ?? 'pass'),
                  decoration: const InputDecoration(labelText: '结果'),
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
                Navigator.pop(ctx, false);
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
                  if (ctx.mounted) {
                    FocusManager.instance.primaryFocus?.unfocus();
                    Navigator.pop(ctx, true);
                  }
                } catch (e) {
                  widget.onMessage(e.toString());
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF128C53),
              ),
              child: const Text('提交'),
            ),
          ],
        );
      }),
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

  Future<void> _setStatusFilter(int? value) async {
    setState(() => _statusFilter = value);
    await _loadByFilters();
  }

  Future<void> _setJobFilter(int? value) async {
    setState(() => _jobIdFilter = value);
    await _loadByFilters();
  }

  Future<void> _resetFilters() async {
    setState(() {
      _statusFilter = null;
      _jobIdFilter = null;
    });
    await _loadByFilters();
  }

  Future<void> _loadByFilters() async {
    await _runAction(() => widget.vm.loadApplications(
          status: _statusFilter,
          jobId: _jobIdFilter,
        ));
  }

  Future<DateTime?> _pickDateTime() async {
    if (!mounted) {
      return null;
    }
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

  Future<DateTime?> _pickDate() async {
    if (!mounted) {
      return null;
    }
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
  }

  Future<void> _runAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      widget.onMessage(e.toString());
    }
  }

  Widget _statusTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7EF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF157347),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
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

  bool _toBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    final text = value?.toString().toLowerCase();
    return text == 'true' || text == '1';
  }

  String? _nullable(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
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

  List<Map<String, dynamic>> _asMapList(dynamic value) {
    if (value is! List) {
      return <Map<String, dynamic>>[];
    }
    return value.map((item) => _asMap(item)).toList();
  }

  String _date(DateTime? value) {
    if (value == null) {
      return '-';
    }
    return '${value.year}-${_two(value.month)}-${_two(value.day)}';
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
