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
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
              itemCount: vm.conversations.length,
              itemBuilder: (_, index) {
                final chat = vm.conversations[index];
                final id = _toInt(chat['id']);
                final title = _toText(chat['counterpartName']);
                final unread = id == null ? 0 : vm.unreadOfConversation(id);
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFEAF1FF),
                      child: Text(
                        (title == '-' ? '企' : title.substring(0, 1)),
                        style: const TextStyle(
                          color: Color(0xFF1E40AF),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    title: Text(
                      title == '-' ? '企业' : title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      _toText(chat['lastMessageContent']) == '-'
                          ? '点击进入会话'
                          : _toText(chat['lastMessageContent']),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
                              context,
                              () => vm.markConversationRead(cid),
                            );
                            if (!context.mounted) {
                              return;
                            }
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StudentChatPage(
                                  baseUrl: baseUrl,
                                  userId: userId,
                                  conversationId: cid,
                                  title: title == '-' ? '企业' : title,
                                ),
                              ),
                            );
                            if (!context.mounted) {
                              return;
                            }
                            await _safeAction(
                              context,
                              () async {
                                await vm.markConversationRead(cid);
                                await vm.loadConversations();
                              },
                            );
                          },
                  ),
                );
              },
            ),
    );
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

  Future<void> _safeAction(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (e) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}
