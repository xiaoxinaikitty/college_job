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
                final title = _toText(chat['counterpartName']);
                final unread = id == null ? 0 : vm.unreadOfConversation(id);
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(title == '-' ? '学生' : title),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (unread > 0) _unreadBadge(unread),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    onTap: id == null
                        ? null
                        : () async {
                            final cid = id;
                            if (cid == null) {
                              return;
                            }
                            await _safeAction(
                                () => vm.markConversationRead(cid));
                            if (!context.mounted) {
                              return;
                            }
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EnterpriseChatPage(
                                  baseUrl: vm.baseUrl,
                                  userId: vm.userId,
                                  conversationId: cid,
                                  title: title == '-' ? '学生' : title,
                                ),
                              ),
                            );
                            if (!context.mounted) {
                              return;
                            }
                            await _safeAction(() async {
                              await vm.markConversationRead(cid);
                              await vm.loadConversations();
                            });
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

  Widget _unreadBadge(int count) {
    final text = count > 99 ? '99+' : '$count';
    return Container(
      constraints: const BoxConstraints(minWidth: 20),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFE53935),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Future<void> _safeAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      onMessage(e.toString());
    }
  }
}
