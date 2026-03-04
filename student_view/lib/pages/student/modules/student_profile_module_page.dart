import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../student_feedback_center_page.dart';
import '../student_interviews_page.dart';
import '../student_report_create_page.dart';
import '../student_review_create_page.dart';
import '../student_resume_editor_page.dart';
import '../../../viewmodels/student_home_view_model.dart';

class StudentProfileModulePage extends StatelessWidget {
  const StudentProfileModulePage({
    super.key,
    required this.vm,
    required this.onMessage,
  });

  final StudentHomeViewModel vm;
  final void Function(String text) onMessage;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          vm.loadResumes(),
          vm.loadOffers(),
          vm.loadInterviews(),
          vm.loadReviews(),
          vm.loadReports(),
        ]);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _resumeCard(context),
          _offerCard(),
          _interviewCard(context),
          _reviewReportCard(context),
        ],
      ),
    );
  }

  Widget _resumeCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('我的简历',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                TextButton(
                  onPressed: () => _uploadResumeFile(context),
                  child: const Text('上传'),
                ),
                TextButton(
                  onPressed: () => _createResume(context),
                  child: const Text('新建'),
                ),
              ],
            ),
            if (vm.resumes.isEmpty) const Text('暂无简历'),
            ...vm.resumes.map((resume) {
              final id = _toInt(resume['id']);
              final isDefault = (_toInt(resume['isDefault']) ?? 0) == 1;
              return ListTile(
                onTap:
                    id == null ? null : () => _editResume(context, resume, id),
                contentPadding: EdgeInsets.zero,
                title: Text(_toText(resume['title'])),
                subtitle: Text(isDefault ? '默认简历' : '普通简历'),
                trailing: isDefault
                    ? const Icon(Icons.check_circle, color: Color(0xFF0B5FFF))
                    : TextButton(
                        onPressed:
                            id == null ? null : () => _setDefaultResume(id),
                        child: const Text('设为默认'),
                      ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _offerCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Offer处理',
                style: TextStyle(fontWeight: FontWeight.w700)),
            if (vm.offers.isEmpty) const Text('暂无Offer'),
            ...vm.offers.map((offer) {
              final id = _toInt(offer['id']);
              final status = _toInt(offer['status']) ?? 0;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Offer #${_toText(offer['id'])}'),
                subtitle: Text('状态: ${_toText(status)}'),
                trailing: status == 1 && id != null
                    ? Wrap(
                        spacing: 6,
                        children: [
                          TextButton(
                            onPressed: () => _runAction(
                              () => vm.offerDecision(
                                  offerId: id, action: 'accept'),
                            ),
                            child: const Text('接受'),
                          ),
                          TextButton(
                            onPressed: () => _runAction(
                              () => vm.offerDecision(
                                  offerId: id, action: 'reject'),
                            ),
                            child: const Text('拒绝'),
                          ),
                        ],
                      )
                    : null,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _reviewReportCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('评价与举报', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('我的评价: ${vm.reviews.length} 条'),
            Text('我的举报: ${vm.reports.length} 条'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilledButton.tonal(
                  onPressed: () => _openReviewPage(context),
                  child: const Text('提交评价'),
                ),
                FilledButton.tonal(
                  onPressed: () => _openReportPage(context),
                  child: const Text('提交举报'),
                ),
                FilledButton.tonal(
                  onPressed: () => _openFeedbackCenter(context),
                  child: const Text('历史记录'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _interviewCard(BuildContext context) {
    final previews = vm.interviews.take(2).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('面试安排',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                Text(
                  '${vm.interviews.length} 条',
                  style:
                      const TextStyle(color: Color(0xFF637083), fontSize: 12),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _openInterviews(context),
                  child: const Text('查看全部'),
                ),
              ],
            ),
            if (vm.interviews.isEmpty)
              const Text('暂无面试安排')
            else
              ...previews.map((interview) {
                final type =
                    _interviewTypeLabel(_toInt(interview['interviewType']));
                final status =
                    _interviewStatusLabel(_toInt(interview['status']));
                final schedule = _formatDateTime(interview['scheduledAt']);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('$type · $status'),
                  subtitle: Text(schedule),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () => _openInterviews(context),
                );
              }),
          ],
        ),
      ),
    );
  }

  Future<void> _openInterviews(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentInterviewsPage(vm: vm, onMessage: onMessage),
      ),
    );
    await _runAction(vm.loadInterviews);
  }

  Future<void> _setDefaultResume(int resumeId) async {
    await _runAction(() => vm.setDefaultResume(resumeId));
  }

  Future<void> _uploadResumeFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'doc', 'docx'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final picked = result.files.first;
    final filePath = picked.path;
    if (filePath == null || filePath.isEmpty) {
      onMessage('当前平台未返回文件路径，暂不支持上传');
      return;
    }

    await _runAction(
      () => vm.uploadResumeFile(
        filePath: filePath,
        fileName: picked.name,
        title: _extractBaseName(picked.name),
      ),
    );
    onMessage('简历上传成功');
  }

  Future<void> _createResume(BuildContext context) async {
    final result = await Navigator.push<ResumeEditorResult>(
      context,
      MaterialPageRoute(builder: (_) => const StudentResumeEditorPage()),
    );
    if (result == null) {
      return;
    }
    await _runAction(
      () => vm.createResume(
        title: result.title,
        contentJson: result.contentJson,
        completionScore: result.completionScore,
      ),
    );
    onMessage('简历创建成功');
  }

  Future<void> _editResume(
    BuildContext context,
    Map<String, dynamic> resume,
    int resumeId,
  ) async {
    final result = await Navigator.push<ResumeEditorResult>(
      context,
      MaterialPageRoute(
        builder: (_) => StudentResumeEditorPage(
          initialTitle: _rawText(resume['title']),
          initialContentJson: _rawText(resume['resumeContentJson']),
        ),
      ),
    );
    if (result == null) {
      return;
    }
    await _runAction(
      () => vm.updateResume(
        resumeId: resumeId,
        title: result.title,
        contentJson: result.contentJson,
        completionScore: result.completionScore,
      ),
    );
    onMessage('简历更新成功');
  }

  Future<void> _openReviewPage(BuildContext context) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => StudentReviewCreatePage(vm: vm, onMessage: onMessage),
      ),
    );
    if (changed == true) {
      await _runAction(vm.loadReviews);
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
      await _runAction(vm.loadReports);
    }
  }

  Future<void> _openFeedbackCenter(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentFeedbackCenterPage(vm: vm, onMessage: onMessage),
      ),
    );
    await _runAction(() async {
      await vm.loadReviews();
      await vm.loadReports();
    });
  }

  Future<void> _createReview(BuildContext context) async {
    final appIdCtl = TextEditingController();
    final enterpriseIdCtl = TextEditingController();
    final contentCtl = TextEditingController();
    final controllers = <TextEditingController>[
      appIdCtl,
      enterpriseIdCtl,
      contentCtl,
    ];
    if (!context.mounted) {
      _disposeControllersSafely(controllers);
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('提交评价'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: appIdCtl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '投递ID'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: enterpriseIdCtl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '企业ID'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: contentCtl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: '评价内容'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              FocusScope.of(dialogContext).unfocus();
              Navigator.of(dialogContext).pop();
            },
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              final applicationId = int.tryParse(appIdCtl.text.trim());
              final enterpriseId = int.tryParse(enterpriseIdCtl.text.trim());
              final content = contentCtl.text.trim();
              if (applicationId == null ||
                  enterpriseId == null ||
                  content.isEmpty) {
                onMessage('请填写完整且合法的数据');
                return;
              }
              if (dialogContext.mounted) {
                FocusScope.of(dialogContext).unfocus();
                Navigator.of(dialogContext).pop();
              }
              await _runAction(
                () => vm.createReview(
                  applicationId: applicationId,
                  enterpriseId: enterpriseId,
                  rating: 5,
                  content: content,
                ),
              );
              onMessage('评价提交成功');
            },
            child: const Text('提交'),
          ),
        ],
      ),
    );
    _disposeControllersSafely(controllers);
  }

  Future<void> _createReport(BuildContext context) async {
    final targetIdCtl = TextEditingController();
    final reasonCtl = TextEditingController();
    final controllers = <TextEditingController>[targetIdCtl, reasonCtl];
    if (!context.mounted) {
      _disposeControllersSafely(controllers);
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('提交举报'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: targetIdCtl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '目标ID'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: reasonCtl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: '举报原因'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              FocusScope.of(dialogContext).unfocus();
              Navigator.of(dialogContext).pop();
            },
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              final targetId = int.tryParse(targetIdCtl.text.trim());
              final reason = reasonCtl.text.trim();
              if (targetId == null || reason.isEmpty) {
                onMessage('请填写完整且合法的数据');
                return;
              }
              if (dialogContext.mounted) {
                FocusScope.of(dialogContext).unfocus();
                Navigator.of(dialogContext).pop();
              }
              await _runAction(
                () => vm.createReport(
                  targetType: 1,
                  targetId: targetId,
                  reason: reason,
                ),
              );
              onMessage('举报提交成功');
            },
            child: const Text('提交'),
          ),
        ],
      ),
    );
    _disposeControllersSafely(controllers);
  }

  String _extractBaseName(String fileName) {
    final index = fileName.lastIndexOf('.');
    if (index <= 0) {
      return fileName;
    }
    return fileName.substring(0, index);
  }

  Future<void> _runAction(Future<void> Function() action) async {
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

  String _toText(dynamic value) => value?.toString() ?? '-';

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

  String _interviewTypeLabel(int? type) {
    switch (type) {
      case 1:
        return '线上面试';
      case 2:
        return '线下面试';
      default:
        return '未知类型';
    }
  }

  String _interviewStatusLabel(int? status) {
    switch (status) {
      case 1:
        return '待面试';
      case 2:
        return '已完成';
      case 3:
        return '已取消';
      default:
        return '状态未知';
    }
  }

  String _formatDateTime(dynamic value) {
    final raw = _toText(value);
    if (raw.isEmpty || raw == '-') {
      return '-';
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
