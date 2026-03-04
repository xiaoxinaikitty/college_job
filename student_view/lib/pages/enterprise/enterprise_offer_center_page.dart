import 'package:flutter/material.dart';

import '../../viewmodels/enterprise_home_view_model.dart';

class EnterpriseOfferCenterPage extends StatelessWidget {
  const EnterpriseOfferCenterPage({
    super.key,
    required this.vm,
    required this.onMessage,
  });

  final EnterpriseHomeViewModel vm;
  final void Function(String text) onMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offer中心'),
        actions: [
          IconButton(
            onPressed: () => _openCreateOffer(context),
            icon: const Icon(Icons.add_circle_outline),
            tooltip: '发放Offer',
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
          animation: vm,
          builder: (_, __) {
            final sent =
                vm.offers.where((item) => _toInt(item['status']) == 1).length;
            final accepted =
                vm.offers.where((item) => _toInt(item['status']) == 2).length;
            final rejected =
                vm.offers.where((item) => _toInt(item['status']) == 3).length;
            return RefreshIndicator(
              onRefresh: () async => _safeAction(() async {
                await vm.loadOffers();
                await vm.loadApplications();
              }),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  _summary(sent, accepted, rejected),
                  const SizedBox(height: 12),
                  if (vm.offers.isEmpty)
                    const _EmptyBlock(text: '暂无Offer记录')
                  else
                    ...vm.offers.map(_offerCard),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _summary(int sent, int accepted, int rejected) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _metric('待学生处理', '$sent', const Color(0xFF8A3FFC)),
            _metric('已接受', '$accepted', const Color(0xFF157347)),
            _metric('已拒绝', '$rejected', const Color(0xFFAA2B2B)),
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

  Widget _offerCard(Map<String, dynamic> offer) {
    final status = _toInt(offer['status']);
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
                    '${_text(offer['studentNickname'])} · ${_text(offer['jobTitle'])}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                _statusTag(_text(offer['statusLabel']), _statusColor(status)),
              ],
            ),
            const SizedBox(height: 8),
            Text('Offer编号: ${_text(offer['offerNo'])}'),
            Text(
                '薪资范围: ${_salaryRange(offer['salaryMin'], offer['salaryMax'])}'),
            Text(
                '实习起止: ${_text(offer['internshipStartDate'])} - ${_text(offer['internshipEndDate'])}'),
            Text('截止时间: ${_formatDateTime(offer['expiresAt'])}'),
            if (_text(offer['decisionAt']) != '-')
              Text('处理时间: ${_formatDateTime(offer['decisionAt'])}'),
            if (_text(offer['rejectReason']) != '-')
              Text('拒绝原因: ${_text(offer['rejectReason'])}'),
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

  Future<void> _openCreateOffer(BuildContext context) async {
    final candidates = vm.applications.where((item) {
      final hasOffer = _bool(item['hasOffer']);
      final status = _toInt(item['status']) ?? 0;
      return !hasOffer && status >= 3 && status <= 5;
    }).toList();
    if (candidates.isEmpty) {
      onMessage('当前没有可发放Offer的候选人');
      return;
    }

    var selectedIndex = 0;
    DateTime? startDate;
    DateTime? endDate;
    DateTime? expireAt;
    final minCtl = TextEditingController();
    final maxCtl = TextEditingController();
    final termCtl = TextEditingController();

    final payload = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (_, setLocal) {
          return AlertDialog(
            title: const Text('发放Offer'),
            content: SizedBox(
              width: 460,
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
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: minCtl,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: '最低薪资'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: maxCtl,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: '最高薪资'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _dateField(
                      label: '开始日期',
                      value: startDate,
                      onPick: () async {
                        final picked = await _pickDate(context);
                        if (picked != null) {
                          setLocal(() => startDate = picked);
                        }
                      },
                    ),
                    _dateField(
                      label: '结束日期',
                      value: endDate,
                      onPick: () async {
                        final picked = await _pickDate(context);
                        if (picked != null) {
                          setLocal(() => endDate = picked);
                        }
                      },
                    ),
                    _dateTimeField(
                      label: 'Offer截止时间',
                      value: expireAt,
                      onPick: () async {
                        final picked = await _pickDateTime(context);
                        if (picked != null) {
                          setLocal(() => expireAt = picked);
                        }
                      },
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
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () {
                  final appId =
                      _toInt(candidates[selectedIndex]['applicationId']);
                  if (appId == null) {
                    onMessage('候选人数据异常，请刷新后重试');
                    return;
                  }
                  FocusScope.of(dialogContext).unfocus();
                  Navigator.of(dialogContext).pop({
                    'applicationId': appId,
                    'salaryMin': double.tryParse(minCtl.text.trim()),
                    'salaryMax': double.tryParse(maxCtl.text.trim()),
                    'internshipStartDate': _dateText(startDate),
                    'internshipEndDate': _dateText(endDate),
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
        },
      ),
    );

    minCtl.dispose();
    maxCtl.dispose();
    termCtl.dispose();

    if (payload == null) {
      return;
    }

    await _safeAction(() async {
      await vm.createOffer(payload);
      onMessage('Offer发放成功');
    });
  }

  Widget _dateField({
    required String label,
    required DateTime? value,
    required Future<void> Function() onPick,
  }) {
    return Row(
      children: [
        Expanded(child: Text('$label: ${_dateText(value) ?? '-'}')),
        TextButton(
          onPressed: onPick,
          child: const Text('选择'),
        ),
      ],
    );
  }

  Widget _dateTimeField({
    required String label,
    required DateTime? value,
    required Future<void> Function() onPick,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$label: ${value == null ? '-' : _formatDateTime(value.toIso8601String())}',
          ),
        ),
        TextButton(
          onPressed: onPick,
          child: const Text('选择'),
        ),
      ],
    );
  }

  Future<DateTime?> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
  }

  Future<DateTime?> _pickDateTime(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null) {
      return null;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
    );
    if (time == null) {
      return null;
    }
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _safeAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      onMessage(e.toString());
    }
  }

  String? _nullable(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  String? _dateText(DateTime? value) {
    if (value == null) {
      return null;
    }
    return '${value.year}-${_two(value.month)}-${_two(value.day)}';
  }

  String _salaryRange(dynamic min, dynamic max) {
    final minText = _text(min);
    final maxText = _text(max);
    if (minText == '-' && maxText == '-') {
      return '面议';
    }
    return '$minText - $maxText';
  }

  Color _statusColor(int? status) {
    switch (status) {
      case 1:
        return const Color(0xFF8A3FFC);
      case 2:
        return const Color(0xFF157347);
      case 3:
      case 4:
        return const Color(0xFFAA2B2B);
      default:
        return const Color(0xFF5B6575);
    }
  }

  bool _bool(dynamic value) {
    if (value is bool) {
      return value;
    }
    final text = value?.toString().toLowerCase();
    return text == 'true' || text == '1';
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
          const Icon(Icons.inbox_outlined, size: 36, color: Color(0xFF95A3B8)),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(color: Color(0xFF6B778C))),
        ],
      ),
    );
  }
}
