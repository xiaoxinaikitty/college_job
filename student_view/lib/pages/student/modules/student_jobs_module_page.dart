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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _keywordCtl,
                  decoration: const InputDecoration(hintText: '搜索岗位关键词'),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.tonal(
                onPressed: () => _runAction(
                    () => widget.vm.loadJobs(keyword: _keywordCtl.text)),
                child: const Text('搜索'),
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
                      Center(child: Text('暂无岗位')),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: widget.vm.jobs.length,
                    itemBuilder: (_, index) {
                      final job = widget.vm.jobs[index];
                      final jobId = _toInt(job['jobId']);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          title: Text(_toText(job['title'])),
                          subtitle: Text(
                            '${_toText(job['enterpriseName'])} · ${_toText(job['city'])}',
                          ),
                          trailing: Wrap(
                            spacing: 6,
                            children: [
                              TextButton(
                                onPressed: jobId == null
                                    ? null
                                    : () => _showJob(jobId),
                                child: const Text('详情'),
                              ),
                              TextButton(
                                onPressed: jobId == null
                                    ? null
                                    : () => _applyJob(jobId),
                                child: const Text('投递'),
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
          content: Text(_toText(detail['description'])),
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

  String _toText(dynamic value) => value?.toString() ?? '-';

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
