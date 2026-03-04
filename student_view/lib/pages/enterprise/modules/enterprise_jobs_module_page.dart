import 'package:flutter/material.dart';

import '../../../viewmodels/enterprise_home_view_model.dart';

class EnterpriseJobsModulePage extends StatefulWidget {
  const EnterpriseJobsModulePage({
    super.key,
    required this.vm,
    required this.onMessage,
  });

  final EnterpriseHomeViewModel vm;
  final void Function(String text) onMessage;

  @override
  State<EnterpriseJobsModulePage> createState() =>
      _EnterpriseJobsModulePageState();
}

class _EnterpriseJobsModulePageState extends State<EnterpriseJobsModulePage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '我的岗位 ${widget.vm.jobs.length} 个',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: () => _openJobEditor(),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF128C53),
                ),
                icon: const Icon(Icons.add),
                label: const Text('发布岗位'),
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
                      Center(child: Text('暂无岗位，点击“发布岗位”开始')),
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
                          contentPadding:
                              const EdgeInsets.fromLTRB(12, 8, 8, 8),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _toText(job['title']),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                              _statusChip(
                                _toText(job['statusLabel']),
                                _toInt(job['status']),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_toText(job['city'])} · ${_toText(job['category'])}',
                                ),
                                Text('薪资: ${_salaryText(job)}'),
                                Text(
                                    '投递数: ${_toText(job['applicationCount'])}'),
                              ],
                            ),
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'detail') {
                                _showDetail(job);
                              } else if (value == 'edit') {
                                _openJobEditor(job: job);
                              } else if (value == 'offline' && jobId != null) {
                                _offlineJob(jobId);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                  value: 'detail', child: Text('查看详情')),
                              PopupMenuItem(value: 'edit', child: Text('编辑岗位')),
                              PopupMenuItem(
                                  value: 'offline', child: Text('下线岗位')),
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

  Widget _statusChip(String label, int? status) {
    Color bg = const Color(0xFFE6ECF3);
    Color fg = const Color(0xFF4A5668);
    if (status == 2) {
      bg = const Color(0xFFFFF1D6);
      fg = const Color(0xFF9B6A00);
    } else if (status == 3) {
      bg = const Color(0xFFDDF5E8);
      fg = const Color(0xFF157347);
    } else if (status == 4 || status == 5) {
      bg = const Color(0xFFFCE2E2);
      fg = const Color(0xFFAB1E1E);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Future<void> _showDetail(Map<String, dynamic> job) async {
    if (!mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_toText(job['title'])),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('状态: ${_toText(job['statusLabel'])}'),
              Text('城市: ${_toText(job['city'])}'),
              Text('分类: ${_toText(job['category'])}'),
              Text('薪资: ${_salaryText(job)}'),
              Text('实习月数: ${_toText(job['internshipMonths'])}'),
              Text('学历要求: ${_toText(job['educationRequirement'])}'),
              const SizedBox(height: 8),
              const Text('岗位描述', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(_toText(job['description'])),
              const SizedBox(height: 8),
              const Text('任职要求', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(_toText(job['requirementText'])),
            ],
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
  }

  Future<void> _offlineJob(int jobId) async {
    if (!mounted) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('下线岗位'),
        content: const Text('确认下线该岗位吗？下线后学生将不可继续投递。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF128C53)),
            child: const Text('确认下线'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await _runAction(() => widget.vm.offlineJob(jobId));
    widget.onMessage('岗位已下线');
  }

  Future<void> _openJobEditor({Map<String, dynamic>? job}) async {
    if (!mounted) {
      return;
    }
    final titleCtl = TextEditingController(text: _rawText(job?['title']));
    final categoryCtl = TextEditingController(text: _rawText(job?['category']));
    final cityCtl = TextEditingController(text: _rawText(job?['city']));
    final salaryMinCtl =
        TextEditingController(text: _rawText(job?['salaryMin']));
    final salaryMaxCtl =
        TextEditingController(text: _rawText(job?['salaryMax']));
    final internshipMonthsCtl = TextEditingController(
      text: _rawText(job?['internshipMonths']),
    );
    final educationCtl = TextEditingController(
      text: _rawText(job?['educationRequirement']),
    );
    final descCtl = TextEditingController(text: _rawText(job?['description']));
    final reqCtl =
        TextEditingController(text: _rawText(job?['requirementText']));
    bool submitForReview = job == null ? false : _toInt(job['status']) == 2;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (ctx) {
        return StatefulBuilder(builder: (_, setLocal) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                16 + MediaQuery.viewInsetsOf(ctx).bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job == null ? '发布岗位' : '编辑岗位',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleCtl,
                      decoration: const InputDecoration(labelText: '岗位标题*'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: categoryCtl,
                      decoration: const InputDecoration(labelText: '岗位分类'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: cityCtl,
                      decoration: const InputDecoration(labelText: '工作城市'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: salaryMinCtl,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: '最低薪资'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: salaryMaxCtl,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: '最高薪资'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: internshipMonthsCtl,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: '实习月数'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: educationCtl,
                            decoration:
                                const InputDecoration(labelText: '学历要求'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descCtl,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(labelText: '岗位描述*'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: reqCtl,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: '任职要求'),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      value: submitForReview,
                      onChanged: (value) =>
                          setLocal(() => submitForReview = value),
                      title: const Text('提交管理员审核'),
                      subtitle: const Text('开启后进入待审核，关闭则直接上线（联调用）'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('取消'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: () async {
                              final title = titleCtl.text.trim();
                              final description = descCtl.text.trim();
                              if (title.isEmpty || description.isEmpty) {
                                widget.onMessage('岗位标题和岗位描述不能为空');
                                return;
                              }
                              final body = <String, dynamic>{
                                'title': title,
                                'category': _nullable(categoryCtl.text),
                                'city': _nullable(cityCtl.text),
                                'salaryMin':
                                    double.tryParse(salaryMinCtl.text.trim()),
                                'salaryMax':
                                    double.tryParse(salaryMaxCtl.text.trim()),
                                'internshipMonths': int.tryParse(
                                  internshipMonthsCtl.text.trim(),
                                ),
                                'educationRequirement':
                                    _nullable(educationCtl.text),
                                'description': description,
                                'requirementText': _nullable(reqCtl.text),
                                'submitForReview': submitForReview,
                              };
                              try {
                                final jobId = _toInt(job?['jobId']);
                                if (jobId == null) {
                                  await widget.vm.createJob(body);
                                } else {
                                  await widget.vm
                                      .updateJob(jobId: jobId, body: body);
                                }
                                if (!ctx.mounted) {
                                  return;
                                }
                                FocusScope.of(ctx).unfocus();
                                Navigator.pop(ctx, true);
                              } catch (e) {
                                widget.onMessage(e.toString());
                              }
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF128C53),
                            ),
                            child: const Text('保存'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
    titleCtl.dispose();
    categoryCtl.dispose();
    cityCtl.dispose();
    salaryMinCtl.dispose();
    salaryMaxCtl.dispose();
    internshipMonthsCtl.dispose();
    educationCtl.dispose();
    descCtl.dispose();
    reqCtl.dispose();

    if (saved == true) {
      widget.onMessage(job == null ? '岗位发布成功' : '岗位更新成功');
    }
  }

  Future<void> _runAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      widget.onMessage(e.toString());
    }
  }

  String _toText(dynamic value) {
    final text = value?.toString();
    if (text == null || text.trim().isEmpty || text == 'null') {
      return '-';
    }
    return text;
  }

  String _rawText(dynamic value) => value?.toString() ?? '';

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
      return '面议';
    }
    return '$min - $max';
  }

  String? _nullable(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }
}
