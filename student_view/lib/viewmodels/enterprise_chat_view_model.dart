import 'package:flutter/material.dart';

import '../services/enterprise_service.dart';

class EnterpriseChatViewModel extends ChangeNotifier {
  EnterpriseChatViewModel({
    required this.baseUrl,
    required this.userId,
    required this.conversationId,
    EnterpriseService? service,
  }) : _service = service ?? EnterpriseService();

  final String baseUrl;
  final int userId;
  final int conversationId;
  final EnterpriseService _service;

  bool _loading = true;
  bool _sending = false;
  List<Map<String, dynamic>> _messages = <Map<String, dynamic>>[];

  bool get loading => _loading;
  bool get sending => _sending;
  List<Map<String, dynamic>> get messages => _messages;

  Future<void> loadMessages() async {
    _loading = true;
    notifyListeners();
    try {
      _messages = await _service.listMessages(
        baseUrl: baseUrl,
        userId: userId,
        conversationId: conversationId,
      );
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> sendText(String text) async {
    final clean = text.trim();
    if (clean.isEmpty) {
      return;
    }
    _sending = true;
    notifyListeners();
    try {
      await _service.sendMessage(
        baseUrl: baseUrl,
        userId: userId,
        conversationId: conversationId,
        messageType: 1,
        contentText: clean,
      );
      _messages = await _service.listMessages(
        baseUrl: baseUrl,
        userId: userId,
        conversationId: conversationId,
      );
    } finally {
      _sending = false;
      notifyListeners();
    }
  }
}
