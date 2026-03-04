import 'dart:async';

import 'package:flutter/material.dart';

import '../models/auth_payload.dart';
import '../services/enterprise_service.dart';

class EnterpriseHomeViewModel extends ChangeNotifier {
  EnterpriseHomeViewModel({
    required this.baseUrl,
    required this.payload,
    EnterpriseService? service,
  }) : _service = service ?? EnterpriseService();

  final String baseUrl;
  final AuthPayload payload;
  final EnterpriseService _service;

  int _tabIndex = 0;
  bool _initialLoading = true;
  bool _busy = false;
  Map<String, dynamic> _profile = <String, dynamic>{};
  List<Map<String, dynamic>> _jobs = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _applications = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _conversations = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _interviews = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _offers = <Map<String, dynamic>>[];
  Map<int, int> _conversationUnread = <int, int>{};
  Map<int, int> _conversationLastReadMessageId = <int, int>{};
  Timer? _conversationPollTimer;
  bool _conversationRefreshing = false;
  bool _disposed = false;

  int get userId => payload.userId;
  int? get enterpriseId => payload.enterpriseId;
  int get tabIndex => _tabIndex;
  bool get initialLoading => _initialLoading;
  bool get busy => _busy;
  Map<String, dynamic> get profile => _profile;
  List<Map<String, dynamic>> get jobs => _jobs;
  List<Map<String, dynamic>> get applications => _applications;
  List<Map<String, dynamic>> get conversations => _conversations;
  List<Map<String, dynamic>> get interviews => _interviews;
  List<Map<String, dynamic>> get offers => _offers;
  int get unreadMessageCount =>
      _conversationUnread.values.fold(0, (sum, item) => sum + item);

  int unreadOfConversation(int conversationId) =>
      _conversationUnread[conversationId] ?? 0;

  void setTabIndex(int index) {
    _tabIndex = index;
    _notifySafely();
    if (index == 2) {
      loadConversations().catchError((_) {});
    }
  }

  Future<void> bootstrap() async {
    _initialLoading = true;
    _notifySafely();
    try {
      await Future.wait([
        loadProfile(),
        loadJobs(),
        loadApplications(),
        loadConversations(),
        loadInterviews(),
        loadOffers(),
      ]);
    } finally {
      _initialLoading = false;
      _notifySafely();
      _startConversationPolling();
    }
  }

  Future<void> loadProfile() async {
    _profile = await _service.profileDetail(baseUrl: baseUrl, userId: userId);
    _notifySafely();
  }

  Future<void> updateProfile(Map<String, dynamic> body) async {
    await _runBusy(() async {
      await _service.updateProfile(
        baseUrl: baseUrl,
        userId: userId,
        body: body,
      );
      await loadProfile();
    });
  }

  Future<void> submitCertification({
    required String licenseFileUrl,
    String? submitRemark,
  }) async {
    await _runBusy(() async {
      await _service.submitCertification(
        baseUrl: baseUrl,
        userId: userId,
        licenseFileUrl: licenseFileUrl,
        submitRemark: submitRemark,
      );
      await loadProfile();
    });
  }

  Future<void> loadJobs() async {
    _jobs = await _service.listJobs(baseUrl: baseUrl, userId: userId);
    _notifySafely();
  }

  Future<void> createJob(Map<String, dynamic> body) async {
    await _runBusy(() async {
      await _service.createJob(baseUrl: baseUrl, userId: userId, body: body);
      await loadJobs();
    });
  }

  Future<void> updateJob({
    required int jobId,
    required Map<String, dynamic> body,
  }) async {
    await _runBusy(() async {
      await _service.updateJob(
        baseUrl: baseUrl,
        userId: userId,
        jobId: jobId,
        body: body,
      );
      await loadJobs();
    });
  }

  Future<void> offlineJob(int jobId) async {
    await _runBusy(() async {
      await _service.offlineJob(
        baseUrl: baseUrl,
        userId: userId,
        jobId: jobId,
      );
      await loadJobs();
    });
  }

  Future<void> loadApplications({int? status, int? jobId}) async {
    _applications = await _service.listApplications(
      baseUrl: baseUrl,
      userId: userId,
      status: status,
      jobId: jobId,
    );
    _notifySafely();
  }

  Future<Map<String, dynamic>> applicationDetail(int applicationId) {
    return _service.applicationDetail(
      baseUrl: baseUrl,
      userId: userId,
      applicationId: applicationId,
    );
  }

  Future<void> updateApplicationStatus({
    required int applicationId,
    required int toStatus,
    String? rejectReason,
    String? note,
  }) async {
    await _runBusy(() async {
      await _service.updateApplicationStatus(
        baseUrl: baseUrl,
        userId: userId,
        applicationId: applicationId,
        toStatus: toStatus,
        rejectReason: rejectReason,
        note: note,
      );
      await Future.wait([
        loadApplications(),
        loadInterviews(),
      ]);
    });
  }

  Future<void> loadConversations() async {
    if (_conversationRefreshing || _disposed) {
      return;
    }
    _conversationRefreshing = true;
    try {
      _conversations =
          await _service.listChats(baseUrl: baseUrl, userId: userId);
      final activeConversationIds = _conversations
          .map((item) => _toInt(item['id']))
          .whereType<int>()
          .toSet();
      _conversationUnread.removeWhere((conversationId, _) =>
          !activeConversationIds.contains(conversationId));
      _conversationLastReadMessageId.removeWhere(
        (conversationId, _) => !activeConversationIds.contains(conversationId),
      );
      await _refreshConversationUnread();
    } finally {
      _conversationRefreshing = false;
    }
    _notifySafely();
  }

  Future<void> markConversationRead(int conversationId) async {
    final messages = await _service.listMessages(
      baseUrl: baseUrl,
      userId: userId,
      conversationId: conversationId,
    );
    _conversationLastReadMessageId[conversationId] =
        _latestIncomingMessageId(messages);
    _conversationUnread[conversationId] = 0;
    _notifySafely();
  }

  Future<List<Map<String, dynamic>>> listMessages(int conversationId) {
    return _service.listMessages(
      baseUrl: baseUrl,
      userId: userId,
      conversationId: conversationId,
    );
  }

  Future<void> sendMessage({
    required int conversationId,
    required String contentText,
  }) async {
    await _service.sendMessage(
      baseUrl: baseUrl,
      userId: userId,
      conversationId: conversationId,
      messageType: 1,
      contentText: contentText,
    );
  }

  Future<void> loadInterviews({int? applicationId}) async {
    _interviews = await _service.listInterviews(
      baseUrl: baseUrl,
      userId: userId,
      applicationId: applicationId,
    );
    _notifySafely();
  }

  Future<void> createInterview(Map<String, dynamic> body) async {
    await _runBusy(() async {
      await _service.createInterview(
          baseUrl: baseUrl, userId: userId, body: body);
      await Future.wait([
        loadInterviews(),
        loadApplications(),
      ]);
    });
  }

  Future<void> submitInterviewResult({
    required int interviewId,
    required String result,
    String? note,
  }) async {
    await _runBusy(() async {
      await _service.submitInterviewResult(
        baseUrl: baseUrl,
        userId: userId,
        interviewId: interviewId,
        result: result,
        note: note,
      );
      await Future.wait([
        loadInterviews(),
        loadApplications(),
      ]);
    });
  }

  Future<void> loadOffers() async {
    _offers = await _service.listOffers(baseUrl: baseUrl, userId: userId);
    _notifySafely();
  }

  Future<void> createOffer(Map<String, dynamic> body) async {
    await _runBusy(() async {
      await _service.createOffer(baseUrl: baseUrl, userId: userId, body: body);
      await Future.wait([
        loadOffers(),
        loadApplications(),
      ]);
    });
  }

  Future<void> _runBusy(Future<void> Function() action) async {
    _busy = true;
    _notifySafely();
    try {
      await action();
    } finally {
      _busy = false;
      _notifySafely();
    }
  }

  Future<void> _refreshConversationUnread() async {
    final nextUnread = <int, int>{};
    for (final item in _conversations) {
      final conversationId = _toInt(item['id']);
      if (conversationId == null) {
        continue;
      }
      List<Map<String, dynamic>> messages;
      try {
        messages = await _service.listMessages(
          baseUrl: baseUrl,
          userId: userId,
          conversationId: conversationId,
        );
      } catch (_) {
        nextUnread[conversationId] = _conversationUnread[conversationId] ?? 0;
        continue;
      }

      if (!_conversationLastReadMessageId.containsKey(conversationId)) {
        // No server-side read state. Use latest outgoing message as baseline.
        // This allows newly received replies to show unread red dots.
        _conversationLastReadMessageId[conversationId] =
            _latestOutgoingMessageId(messages);
      }

      final lastReadId = _conversationLastReadMessageId[conversationId] ?? 0;
      int unread = 0;
      for (final message in messages) {
        final senderId = _toInt(message['senderUserId']);
        final messageOrder = _messageOrderValue(message);
        if (senderId != userId && messageOrder > lastReadId) {
          unread++;
        }
      }
      nextUnread[conversationId] = unread;
    }
    _conversationUnread = nextUnread;
  }

  int _latestIncomingMessageId(List<Map<String, dynamic>> messages) {
    int latestIncomingId = 0;
    for (final message in messages) {
      final senderId = _toInt(message['senderUserId']);
      final messageOrder = _messageOrderValue(message);
      if (senderId != userId && messageOrder > latestIncomingId) {
        latestIncomingId = messageOrder;
      }
    }
    return latestIncomingId;
  }

  int _latestOutgoingMessageId(List<Map<String, dynamic>> messages) {
    int latestOutgoingId = 0;
    for (final message in messages) {
      final senderId = _toInt(message['senderUserId']);
      final messageOrder = _messageOrderValue(message);
      if (senderId == userId && messageOrder > latestOutgoingId) {
        latestOutgoingId = messageOrder;
      }
    }
    return latestOutgoingId;
  }

  void _startConversationPolling() {
    _conversationPollTimer?.cancel();
    _conversationPollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (_disposed) {
        return;
      }
      loadConversations().catchError((_) {});
    });
  }

  void _notifySafely() {
    if (_disposed) {
      return;
    }
    notifyListeners();
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

  int _messageOrderValue(Map<String, dynamic> message) {
    final id = _toInt(message['id']) ?? 0;
    final sentAtRaw = message['sentAt']?.toString();
    final sentAt = sentAtRaw == null ? null : DateTime.tryParse(sentAtRaw);
    if (sentAt == null) {
      return id;
    }
    final micros = sentAt.toUtc().microsecondsSinceEpoch;
    return micros * 1000000 + (id % 1000000);
  }

  @override
  void dispose() {
    _disposed = true;
    _conversationPollTimer?.cancel();
    super.dispose();
  }
}
