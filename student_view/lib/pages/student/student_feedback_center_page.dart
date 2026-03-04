import 'package:flutter/material.dart';

import '../../viewmodels/student_home_view_model.dart';
import 'student_report_create_page.dart';
import 'student_review_create_page.dart';

class StudentFeedbackCenterPage extends StatelessWidget {
  const StudentFeedbackCenterPage({
    super.key,
    required this.vm,
    required this.onMessage,
  });

  final StudentHomeViewModel vm;
  final void Function(String text) onMessage;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('反馈与治理中心'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '我的评价'),
              Tab(text: '我的举报'),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'review') {
                  await _openReviewPage(context);
                } else {
                  await _openReportPage(context);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'review', child: Text('去评价页面')),
                PopupMenuItem(value: 'report', child: Text('去举报页面')),
              ],
            ),
          ],
        ),
        body: AnimatedBuilder(
          animation: vm,
          builder: (_, __) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: () => _openReviewPage(context),
                        icon: const Icon(Icons.rate_review_outlined),
                        label: const Text('去评价页面'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: () => _openReportPage(context),
                        icon: const Icon(Icons.gpp_bad_outlined),
                        label: const Text('去举报页面'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TabBarView(
                  children: [
                    _reviewsTab(),
                    _reportsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reviewsTab() {
    return RefreshIndicator(
      onRefresh: () async => _safeAction(vm.loadReviews),
      child: vm.reviews.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 120),
                Center(child: Text('暂无评价记录')),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: vm.reviews.length,
              itemBuilder: (_, index) {
                final item = vm.reviews[index];
                final rating = _toInt(item['rating']) ?? 0;
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
                                '企业ID: ${_text(item['enterpriseId'])}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                            Text('评分: $rating/5'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(_text(item['content'])),
                        const SizedBox(height: 6),
                        Text(
                          _formatDateTime(item['createdAt']),
                          style: const TextStyle(
                              color: Color(0xFF6B778C), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _reportsTab() {
    return RefreshIndicator(
      onRefresh: () async => _safeAction(vm.loadReports),
      child: vm.reports.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 120),
                Center(child: Text('暂无举报记录')),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: vm.reports.length,
              itemBuilder: (_, index) {
                final item = vm.reports[index];
                final status = _toInt(item['status']) ?? 1;
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
                                '举报ID: ${_text(item['id'])}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                            _statusTag(
                                _reportStatus(status), _statusColor(status)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                            '目标类型: ${_targetTypeLabel(_toInt(item['targetType']))}'),
                        Text('目标ID: ${_text(item['targetId'])}'),
                        Text('原因: ${_text(item['reason'])}'),
                        if (_text(item['handleResult']) != '-')
                          Text('处理结果: ${_text(item['handleResult'])}'),
                        const SizedBox(height: 6),
                        Text(
                          _formatDateTime(item['createdAt']),
                          style: const TextStyle(
                              color: Color(0xFF6B778C), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
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

  Future<void> _createReview(BuildContext context) async {
    final candidates = vm.applications.where((item) {
      final status = _toInt(item['status']) ?? 0;
      return status == 6 || status == 7;
    }).toList();
    if (candidates.isEmpty) {
      onMessage('仅流程结束后可评价，当前无可评价投递');
      return;
    }
    int selectedIndex = 0;
    var rating = 5;
    final contentCtl = TextEditingController();
    final controllers = <TextEditingController>[contentCtl];
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (_, setLocal) {
          return AlertDialog(
            title: const Text('提交评价'),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: selectedIndex,
                    decoration: const InputDecoration(labelText: '选择投递记录'),
                    items: [
                      for (var i = 0; i < candidates.length; i++)
                        DropdownMenuItem<int>(
                          value: i,
                          child: Text(_text(candidates[i]['applicationNo'])),
                        ),
                    ],
                    onChanged: (value) =>
                        setLocal(() => selectedIndex = value ?? 0),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: rating,
                    decoration: const InputDecoration(labelText: '评分'),
                    items: const [
                      DropdownMenuItem(value: 5, child: Text('5 分')),
                      DropdownMenuItem(value: 4, child: Text('4 分')),
                      DropdownMenuItem(value: 3, child: Text('3 分')),
                      DropdownMenuItem(value: 2, child: Text('2 分')),
                      DropdownMenuItem(value: 1, child: Text('1 分')),
                    ],
                    onChanged: (value) => setLocal(() => rating = value ?? 5),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: contentCtl,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(labelText: '评价内容'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  FocusScope.of(dialogContext).unfocus();
                  Navigator.of(dialogContext).pop(false);
                },
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () async {
                  final content = contentCtl.text.trim();
                  if (content.isEmpty) {
                    onMessage('请填写评价内容');
                    return;
                  }
                  final app = candidates[selectedIndex];
                  final appId = _toInt(app['applicationId']);
                  final enterpriseId = _toInt(app['enterpriseId']);
                  if (appId == null || enterpriseId == null) {
                    onMessage('投递数据异常，请刷新后重试');
                    return;
                  }
                  try {
                    await vm.createReview(
                      applicationId: appId,
                      enterpriseId: enterpriseId,
                      rating: rating,
                      content: content,
                    );
                    if (dialogContext.mounted) {
                      FocusScope.of(dialogContext).unfocus();
                      Navigator.of(dialogContext).pop(true);
                    }
                  } catch (e) {
                    onMessage(e.toString());
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
      onMessage('评价提交成功');
      await _safeAction(vm.loadReviews);
    }
  }

  Future<void> _createReport(BuildContext context) async {
    var targetType = 1;
    final targetCtl = TextEditingController();
    final reasonCtl = TextEditingController();
    final evidenceCtl = TextEditingController();
    final controllers = <TextEditingController>[
      targetCtl,
      reasonCtl,
      evidenceCtl,
    ];
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (_, setLocal) {
          return AlertDialog(
            title: const Text('提交举报'),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: targetType,
                    decoration: const InputDecoration(labelText: '目标类型'),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('岗位')),
                      DropdownMenuItem(value: 2, child: Text('企业')),
                      DropdownMenuItem(value: 3, child: Text('用户')),
                      DropdownMenuItem(value: 4, child: Text('消息')),
                    ],
                    onChanged: (value) =>
                        setLocal(() => targetType = value ?? 1),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: targetCtl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '目标ID'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: reasonCtl,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: '举报原因'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: evidenceCtl,
                    decoration: const InputDecoration(labelText: '证据链接(可选)'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  FocusScope.of(dialogContext).unfocus();
                  Navigator.of(dialogContext).pop(false);
                },
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () async {
                  final targetId = int.tryParse(targetCtl.text.trim());
                  final reason = reasonCtl.text.trim();
                  if (targetId == null || reason.isEmpty) {
                    onMessage('请填写完整举报信息');
                    return;
                  }
                  try {
                    await vm.createReport(
                      targetType: targetType,
                      targetId: targetId,
                      reason: reason,
                      evidenceUrl: evidenceCtl.text.trim().isEmpty
                          ? null
                          : evidenceCtl.text.trim(),
                    );
                    if (dialogContext.mounted) {
                      FocusScope.of(dialogContext).unfocus();
                      Navigator.of(dialogContext).pop(true);
                    }
                  } catch (e) {
                    onMessage(e.toString());
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
      onMessage('举报提交成功');
      await _safeAction(vm.loadReports);
    }
  }

  Future<void> _openReviewPage(BuildContext context) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => StudentReviewCreatePage(vm: vm, onMessage: onMessage),
      ),
    );
    if (changed == true) {
      await _safeAction(() async {
        await vm.loadReviews();
        await vm.loadApplications();
      });
    }
  }

  Future<void> _openReportPage(BuildContext context) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => StudentReportCreatePage(vm: vm, onMessage: onMessage),
      ),
    );
    if (changed == true) {
      await _safeAction(() async {
        await vm.loadReports();
        await vm.loadConversations();
      });
    }
  }

  Future<void> _safeAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      onMessage(e.toString());
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

  String _reportStatus(int status) {
    switch (status) {
      case 1:
        return '待处理';
      case 2:
        return '处理中';
      case 3:
        return '已结案';
      default:
        return '未知';
    }
  }

  Color _statusColor(int status) {
    switch (status) {
      case 2:
        return const Color(0xFF2F6BFF);
      case 3:
        return const Color(0xFF157347);
      default:
        return const Color(0xFFAA2B2B);
    }
  }

  String _targetTypeLabel(int? type) {
    switch (type) {
      case 1:
        return '岗位';
      case 2:
        return '企业';
      case 3:
        return '用户';
      case 4:
        return '消息';
      default:
        return '未知';
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
