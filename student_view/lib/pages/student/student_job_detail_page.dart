import 'package:flutter/material.dart';

import '../../viewmodels/student_home_view_model.dart';

class StudentJobDetailPage extends StatefulWidget {
  const StudentJobDetailPage({
    super.key,
    required this.vm,
    required this.jobId,
    required this.jobSummary,
    required this.onMessage,
  });

  final StudentHomeViewModel vm;
  final int jobId;
  final Map<String, dynamic> jobSummary;
  final void Function(String text) onMessage;

  @override
  State<StudentJobDetailPage> createState() => _StudentJobDetailPageState();
}

class _StudentJobDetailPageState extends State<StudentJobDetailPage> {
  Map<String, dynamic>? _detail;
  bool _loading = true;
  bool _applying = false;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  @override
  Widget build(BuildContext context) {
    final detail = _detail ?? widget.jobSummary;
    return Scaffold(
      appBar: AppBar(title: const Text('岗位详情')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0F5FF), Colors.white],
          ),
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                children: [
                  _headerCard(detail),
                  const SizedBox(height: 12),
                  _sectionCard(
                    title: '岗位介绍',
                    content: _toText(detail['description']),
                  ),
                  const SizedBox(height: 12),
                  _sectionCard(
                    title: '任职要求',
                    content: _toText(detail['requirementText']),
                  ),
                  const SizedBox(height: 12),
                  _infoCard(detail),
                ],
              ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('返回'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: _applying ? null : _applyJob,
                  child: _applying
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('立即投递'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerCard(Map<String, dynamic> detail) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _toText(detail['title']),
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _tag(_toText(detail['enterpriseName'])),
                _tag(_toText(detail['city'])),
                _tag(_salaryText(detail)),
                _tag(_toText(detail['category'])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required String content}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content == '-' ? '暂无信息' : content,
              style: const TextStyle(
                color: Color(0xFF334155),
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(Map<String, dynamic> detail) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '岗位信息',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            _kv('学历要求', _toText(detail['educationRequirement'])),
            _kv('实习时长', _internshipText(detail['internshipMonths'])),
            _kv('发布时间', _toText(detail['createdAt'])),
          ],
        ),
      ),
    );
  }

  Widget _kv(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(
              key,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5FD),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF475569),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _loadDetail() async {
    try {
      final detail = await widget.vm.jobDetail(widget.jobId);
      if (!mounted) {
        return;
      }
      setState(() {
        _detail = detail;
        _loading = false;
      });
    } catch (e) {
      widget.onMessage(e.toString());
      if (!mounted) {
        return;
      }
      setState(() {
        _detail = widget.jobSummary;
        _loading = false;
      });
    }
  }

  Future<void> _applyJob() async {
    if (widget.vm.resumes.isEmpty) {
      widget.onMessage('请先创建简历');
      return;
    }
    final resumeId =
        widget.vm.defaultResumeId() ?? _toInt(widget.vm.resumes.first['id']);
    if (resumeId == null) {
      widget.onMessage('未找到可用简历');
      return;
    }
    setState(() => _applying = true);
    try {
      await widget.vm.applyJob(jobId: widget.jobId, resumeId: resumeId);
      widget.onMessage('投递成功');
    } catch (e) {
      widget.onMessage(e.toString());
    } finally {
      if (mounted) {
        setState(() => _applying = false);
      }
    }
  }

  String _salaryText(Map<String, dynamic> job) {
    final min = _toText(job['salaryMin']);
    final max = _toText(job['salaryMax']);
    if (min == '-' && max == '-') {
      return '薪资面议';
    }
    return '$min-$max';
  }

  String _internshipText(dynamic value) {
    final months = _toText(value);
    if (months == '-') {
      return months;
    }
    return '$months 个月';
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
