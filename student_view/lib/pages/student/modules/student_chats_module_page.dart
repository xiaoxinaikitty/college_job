import 'package:flutter/material.dart';

import '../../../viewmodels/student_home_view_model.dart';
import '../student_chat_page.dart';

class StudentChatsModulePage extends StatelessWidget {
  const StudentChatsModulePage({
    super.key,
    required this.vm,
    required this.baseUrl,
    required this.userId,
  });

  final StudentHomeViewModel vm;
  final String baseUrl;
  final int userId;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: vm.loadConversations,
      child: vm.conversations.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 120),
                Center(child: Text('暂无会话')),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: vm.conversations.length,
              itemBuilder: (_, index) {
                final chat = vm.conversations[index];
                final id = _toInt(chat['id']);
                return Card(
                  child: ListTile(
                    title: Text('会话 #${_toText(chat['id'])}'),
                    subtitle: Text('投递ID: ${_toText(chat['applicationId'])}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: id == null
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StudentChatPage(
                                  baseUrl: baseUrl,
                                  userId: userId,
                                  conversationId: id,
                                ),
                              ),
                            );
                          },
                  ),
                );
              },
            ),
    );
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
