import 'package:flutter/material.dart';

import '../../../viewmodels/student_home_view_model.dart';

class StudentJobsModulePage extends StatefulWidget {
  const StudentJobsModulePage({
    super.key,
    required this.vm,
    required this.onMessage,
  });

  final StudentHomeViewModel vm;
  final void Function(String text) onMessage;

  @override
  State<StudentJobsModulePage> createState() => _StudentJobsModulePageState();
}

class _StudentJobsModulePageState extends State<StudentJobsModulePage> {
  final TextEditingController _keywordCtl = TextEditingController();

  @override
  void dispose() {
    _keywordCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.vm.jobs.length;
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F9FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFDCE8FA)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.travel_explore_rounded,
                      size: 18, color: Color(0xFF2667FF)),
                  const SizedBox(width: 6),
                  Text(
                    '发现岗位',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  Text(
                    '$total 个职位',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _keywordCtl,
                      decoration: const InputDecoration(
                        hintText: '搜索岗位关键词，例如：Java / 产品 / 设计',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                      onSubmitted: (_) => _search(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonal(
                    onPressed: _search,
                    child: const Text('搜索'),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: widget.vm.loadJobs,
            child: widget.vm.jobs.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 120),
                      Center(child: Text('暂无岗位数据')),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                    itemCount: widget.vm.jobs.length,
                    itemBuilder: (_, index) {
                      final job = widget.vm.jobs[index];
                      final jobId = _toInt(job['jobId']);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _toText(job['title']),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: [
                                    _tag(_toText(job['enterpriseName'])),
                                    _tag(_toText(job['city'])),
                                    _tag(_salaryText(job)),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    TextButton(
                                      onPressed: jobId == null
                                          ? null
                                          : () => _showJob(jobId),
                                      child: const Text('查看详情'),
                                    ),
                                    const SizedBox(width: 4),
                                    FilledButton.tonal(
                                      onPressed: jobId == null
                                          ? null
                                          : () => _applyJob(jobId),
                                      child: const Text('投递'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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

  Future<void> _search() async {
    await _runAction(() => widget.vm.loadJobs(keyword: _keywordCtl.text));
  }

  Future<void> _showJob(int jobId) async {
    await _runAction(() async {
      final detail = await widget.vm.jobDetail(jobId);
      if (!mounted) {
        return;
      }
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(_toText(detail['title'])),
          content: SingleChildScrollView(
            child: Text(_toText(detail['description'])),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('关闭'),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _applyJob(int jobId) async {
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
    await _runAction(
        () => widget.vm.applyJob(jobId: jobId, resumeId: resumeId));
    widget.onMessage('投递成功');
  }

  Future<void> _runAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      widget.onMessage(e.toString());
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

  String _salaryText(Map<String, dynamic> job) {
    final min = _toText(job['salaryMin']);
    final max = _toText(job['salaryMax']);
    if (min == '-' && max == '-') {
      return '薪资面议';
    }
    return '$min-$max';
  }
}
