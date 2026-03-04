import 'package:flutter/material.dart';

import '../../../viewmodels/student_home_view_model.dart';

class StudentApplicationsModulePage extends StatelessWidget {
  const StudentApplicationsModulePage({
    super.key,
    required this.vm,
    required this.onMessage,
  });

  final StudentHomeViewModel vm;
  final void Function(String text) onMessage;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: vm.loadApplications,
      child: vm.applications.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 120),
                Center(child: Text('暂无投递记录')),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: vm.applications.length,
              itemBuilder: (_, index) {
                final app = vm.applications[index];
                final applicationId = _toInt(app['applicationId']);
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text('投递号: ${_toText(app['applicationNo'])}'),
                    subtitle: Text(
                      '状态: ${_toText(app['status'])}  岗位:${_toText(app['jobId'])}',
                    ),
                    trailing: TextButton(
                      onPressed: applicationId == null
                          ? null
                          : () => _showStatusLogs(context, applicationId),
                      child: const Text('流转'),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _showStatusLogs(BuildContext context, int applicationId) async {
    try {
      final data = await vm.applicationDetail(applicationId);
      final logs = (data['statusLogs'] as List<dynamic>? ?? [])
          .map((e) => e is Map<String, dynamic>
              ? e
              : (e as Map).map((k, v) => MapEntry(k.toString(), v)))
          .toList();
      if (!context.mounted) {
        return;
      }
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('状态流转日志'),
          content: SizedBox(
            width: double.maxFinite,
            child: logs.isEmpty
                ? const Text('暂无日志')
                : ListView.separated(
                    shrinkWrap: true,
                    itemBuilder: (_, index) {
                      final log = logs[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '${_toText(log['fromStatus'])} -> ${_toText(log['toStatus'])}',
                        ),
                        subtitle: Text(_toText(log['note'])),
                      );
                    },
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemCount: logs.length,
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
