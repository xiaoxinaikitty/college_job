import 'package:flutter/material.dart';

import '../../viewmodels/enterprise_chat_view_model.dart';

class EnterpriseChatPage extends StatefulWidget {
  const EnterpriseChatPage({
    super.key,
    required this.baseUrl,
    required this.userId,
    required this.conversationId,
    this.title,
  });

  final String baseUrl;
  final int userId;
  final int conversationId;
  final String? title;

  @override
  State<EnterpriseChatPage> createState() => _EnterpriseChatPageState();
}

class _EnterpriseChatPageState extends State<EnterpriseChatPage> {
  late final EnterpriseChatViewModel _viewModel;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = EnterpriseChatViewModel(
      baseUrl: widget.baseUrl,
      userId: widget.userId,
      conversationId: widget.conversationId,
    )..addListener(_onChanged);
    _viewModel.loadMessages().catchError((e) {
      if (mounted) {
        _showMessage(e.toString());
      }
    });
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    _viewModel.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? '会话 #${widget.conversationId}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _viewModel.loading
                ? const Center(child: CircularProgressIndicator())
                : _viewModel.messages.isEmpty
                    ? const Center(child: Text('暂无消息'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _viewModel.messages.length,
                        itemBuilder: (_, index) {
                          final item = _viewModel.messages[index];
                          final senderId = _toInt(item['senderUserId']);
                          final mine = senderId == widget.userId;
                          return Align(
                            alignment: mine
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              constraints: const BoxConstraints(maxWidth: 280),
                              decoration: BoxDecoration(
                                color: mine
                                    ? const Color(0xFF128C53)
                                    : const Color(0xFFEAF7EF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _toText(item['contentText']),
                                style: TextStyle(
                                  color: mine
                                      ? Colors.white
                                      : const Color(0xFF1F2D45),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: '输入消息内容',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _viewModel.sending ? null : _send,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF128C53),
                    ),
                    child: _viewModel.sending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('发送'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      return;
    }
    _controller.clear();
    try {
      await _viewModel.sendText(text);
    } catch (e) {
      if (!mounted) {
        return;
      }
      _showMessage(e.toString());
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  String _toText(dynamic value) => value?.toString() ?? '';

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
