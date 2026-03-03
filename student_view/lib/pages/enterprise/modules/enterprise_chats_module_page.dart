import 'package:flutter/material.dart';

import '../../../viewmodels/enterprise_home_view_model.dart';
import '../enterprise_chat_page.dart';

class EnterpriseChatsModulePage extends StatelessWidget {
  const EnterpriseChatsModulePage({
    super.key,
    required this.vm,
    required this.onMessage,
  });

  final EnterpriseHomeViewModel vm;
  final void Function(String text) onMessage;

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
                final studentUserId = _toText(chat['studentUserId']);
                final subtitle = '申请ID: ${_toText(chat['applicationId'])}';
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text('学生 $studentUserId'),
                    subtitle: Text(subtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: id == null
                        ? null
                        : () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EnterpriseChatPage(
                                  baseUrl: vm.baseUrl,
                                  userId: vm.userId,
                                  conversationId: id,
                                  title: '会话 #$id',
                                ),
                              ),
                            );
                            try {
                              await vm.loadConversations();
                            } catch (e) {
                              onMessage(e.toString());
                            }
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
