import 'package:flutter/material.dart';

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
          vm.loadReviews(),
          vm.loadReports(),
        ]);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _resumeCard(context),
          _offerCard(),
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
                  onPressed: () => _createReview(context),
                  child: const Text('提交评价'),
                ),
                FilledButton.tonal(
                  onPressed: () => _createReport(context),
                  child: const Text('提交举报'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setDefaultResume(int resumeId) async {
    await _runAction(() => vm.setDefaultResume(resumeId));
  }

  Future<void> _createResume(BuildContext context) async {
    final titleCtl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('新建简历'),
        content: TextField(
          controller: titleCtl,
          decoration: const InputDecoration(hintText: '简历标题'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              final title = titleCtl.text.trim();
              if (title.isEmpty) {
                onMessage('请输入标题');
                return;
              }
              Navigator.pop(context);
              await _runAction(() => vm.createResume(
                    title: title,
                    contentJson: '{"education":[],"skills":[]}',
                  ));
              onMessage('创建成功');
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  Future<void> _createReview(BuildContext context) async {
    final appIdCtl = TextEditingController();
    final enterpriseIdCtl = TextEditingController();
    final contentCtl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
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
            onPressed: () => Navigator.pop(context),
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
              Navigator.pop(context);
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
  }

  Future<void> _createReport(BuildContext context) async {
    final targetIdCtl = TextEditingController();
    final reasonCtl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
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
            onPressed: () => Navigator.pop(context),
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
              Navigator.pop(context);
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
  }

  Future<void> _runAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      onMessage(e.toString());
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
