import 'package:flutter/material.dart';

import '../../viewmodels/student_home_view_model.dart';

class StudentReviewCreatePage extends StatefulWidget {
  const StudentReviewCreatePage({
    super.key,
    required this.vm,
    required this.onMessage,
  });

  final StudentHomeViewModel vm;
  final void Function(String text) onMessage;

  @override
  State<StudentReviewCreatePage> createState() =>
      _StudentReviewCreatePageState();
}

class _StudentReviewCreatePageState extends State<StudentReviewCreatePage> {
  final TextEditingController _contentCtl = TextEditingController();
  int _rating = 5;
  int _selectedIndex = 0;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _prepareData();
  }

  @override
  void dispose() {
    _contentCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = _reviewEntries();
    final canSubmit = entries.isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: const Text('提交评价')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0F5FF), Colors.white],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _tipCard(),
            const SizedBox(height: 12),
            if (!canSubmit)
              _emptyCard()
            else ...[
              _targetCard(entries),
              const SizedBox(height: 12),
              _ratingCard(),
              const SizedBox(height: 12),
              _contentCard(),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: _submitting ? null : () => _submit(entries),
                child: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('提交评价'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tipCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Icon(Icons.info_outline_rounded, color: Color(0xFF2667FF)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                '仅展示可评价的已结束投递记录，系统将自动关联企业与投递信息。',
                style: TextStyle(color: Color(0xFF475569), height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 14),
        child: Column(
          children: const [
            Icon(Icons.rate_review_outlined,
                size: 34, color: Color(0xFF94A3B8)),
            SizedBox(height: 8),
            Text(
              '暂无可评价记录',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 4),
            Text(
              '请等待投递流程结束后再评价',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _targetCard(List<_ReviewEntry> entries) {
    if (_selectedIndex >= entries.length) {
      _selectedIndex = 0;
    }
    final selected = entries[_selectedIndex];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '评价对象',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _selectedIndex,
              decoration: const InputDecoration(labelText: '选择企业与投递记录'),
              items: [
                for (var i = 0; i < entries.length; i++)
                  DropdownMenuItem<int>(
                    value: i,
                    child: Text(
                      '${entries[i].enterpriseName} · ${entries[i].jobTitle}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (value) => setState(() => _selectedIndex = value ?? 0),
            ),
            const SizedBox(height: 8),
            _kv('企业', selected.enterpriseName),
            _kv('岗位', selected.jobTitle),
            _kv('投递编号', selected.applicationNo),
          ],
        ),
      ),
    );
  }

  Widget _ratingCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('评分', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _rating,
              decoration: const InputDecoration(labelText: '选择评分'),
              items: const [
                DropdownMenuItem(value: 5, child: Text('5 分（非常满意）')),
                DropdownMenuItem(value: 4, child: Text('4 分（满意）')),
                DropdownMenuItem(value: 3, child: Text('3 分（一般）')),
                DropdownMenuItem(value: 2, child: Text('2 分（不满意）')),
                DropdownMenuItem(value: 1, child: Text('1 分（很差）')),
              ],
              onChanged: (value) => setState(() => _rating = value ?? 5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contentCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: TextField(
          controller: _contentCtl,
          minLines: 4,
          maxLines: 7,
          decoration: const InputDecoration(
            labelText: '评价内容',
            hintText: '请客观描述企业沟通效率、面试体验、岗位真实性等',
          ),
        ),
      ),
    );
  }

  Widget _kv(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 68,
            child: Text(
              key,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _prepareData() async {
    try {
      await Future.wait([
        widget.vm.loadApplications(),
        widget.vm.loadReviews(),
      ]);
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      widget.onMessage(e.toString());
    }
  }

  List<_ReviewEntry> _reviewEntries() {
    final records = <String, _ReviewEntry>{};
    for (final item in widget.vm.applications) {
      final status = _toInt(item['status']) ?? 0;
      if (status != 6 && status != 7) {
        continue;
      }
      final applicationId = _toInt(item['applicationId']);
      final enterpriseId = _toInt(item['enterpriseId']);
      if (applicationId == null || enterpriseId == null) {
        continue;
      }
      final key = '$applicationId-$enterpriseId';
      records[key] = _ReviewEntry(
        applicationId: applicationId,
        enterpriseId: enterpriseId,
        enterpriseName: _toText(item['enterpriseName']),
        jobTitle: _toText(item['jobTitle']),
        applicationNo: _toText(item['applicationNo']),
      );
    }
    return records.values.toList();
  }

  Future<void> _submit(List<_ReviewEntry> entries) async {
    if (entries.isEmpty) {
      widget.onMessage('暂无可评价记录');
      return;
    }
    final content = _contentCtl.text.trim();
    if (content.isEmpty) {
      widget.onMessage('请填写评价内容');
      return;
    }
    final selected = entries[_selectedIndex];
    setState(() => _submitting = true);
    try {
      await widget.vm.createReview(
        applicationId: selected.applicationId,
        enterpriseId: selected.enterpriseId,
        rating: _rating,
        content: content,
      );
      widget.onMessage('评价提交成功');
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

class _ReviewEntry {
  const _ReviewEntry({
    required this.applicationId,
    required this.enterpriseId,
    required this.enterpriseName,
    required this.jobTitle,
    required this.applicationNo,
  });

  final int applicationId;
  final int enterpriseId;
  final String enterpriseName;
  final String jobTitle;
  final String applicationNo;
}
