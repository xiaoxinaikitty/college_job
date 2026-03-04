import 'dart:async';

import 'package:flutter/material.dart';

import '../models/auth_payload.dart';
import '../services/student_service.dart';

class StudentHomeViewModel extends ChangeNotifier {
  StudentHomeViewModel({
    required this.baseUrl,
    required this.payload,
    StudentService? service,
  }) : _service = service ?? StudentService();

  final String baseUrl;
  final AuthPayload payload;
  final StudentService _service;

  int _tabIndex = 0;
  bool _initialLoading = true;
  bool _busy = false;
  String _jobKeyword = '';

  List<Map<String, dynamic>> _jobs = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _applications = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _conversations = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _resumes = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _offers = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _interviews = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _reviews = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _reports = <Map<String, dynamic>>[];
  Map<int, int> _conversationUnread = <int, int>{};
  Map<int, int> _conversationLastReadMessageId = <int, int>{};
  Timer? _conversationPollTimer;
  bool _conversationRefreshing = false;
  bool _disposed = false;
  final Map<int, Map<String, dynamic>> _interviewConfirmStates =
      <int, Map<String, dynamic>>{};

  int get userId => payload.userId;
  int get tabIndex => _tabIndex;
  bool get initialLoading => _initialLoading;
  bool get busy => _busy;
  String get jobKeyword => _jobKeyword;
  List<Map<String, dynamic>> get jobs => _jobs;
  List<Map<String, dynamic>> get applications => _applications;
  List<Map<String, dynamic>> get conversations => _conversations;
  List<Map<String, dynamic>> get resumes => _resumes;
  List<Map<String, dynamic>> get offers => _offers;
  List<Map<String, dynamic>> get interviews => _interviews;
  List<Map<String, dynamic>> get reviews => _reviews;
  List<Map<String, dynamic>> get reports => _reports;
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
        loadJobs(),
        loadApplications(),
        loadConversations(),
        loadResumes(),
        loadOffers(),
        loadInterviews(),
        loadReviews(),
        loadReports(),
      ]);
    } finally {
      _initialLoading = false;
      _notifySafely();
      _startConversationPolling();
    }
  }

  Future<void> loadJobs({String? keyword}) async {
    if (keyword != null) {
      _jobKeyword = keyword.trim();
    }
    final pageResult = await _service.listJobs(
      baseUrl: baseUrl,
      keyword: _jobKeyword.isEmpty ? null : _jobKeyword,
      page: 0,
      size: 20,
    );
    _jobs = pageResult.records;
    _notifySafely();
  }

  Future<Map<String, dynamic>> jobDetail(int jobId) {
    return _service.jobDetail(baseUrl: baseUrl, jobId: jobId);
  }

  Future<void> loadApplications() async {
    _applications = await _service.listApplications(
      baseUrl: baseUrl,
      userId: userId,
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

  Future<void> loadConversations() async {
    if (_conversationRefreshing || _disposed) {
      return;
    }
    _conversationRefreshing = true;
    try {
      _conversations = await _service.listChats(
        baseUrl: baseUrl,
        userId: userId,
      );
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

  Future<void> loadResumes() async {
    _resumes = await _service.listResumes(
      baseUrl: baseUrl,
      userId: userId,
    );
    _notifySafely();
  }

  Future<void> createResume({
    required String title,
    required String contentJson,
    double? completionScore,
  }) async {
    await _runBusy(() async {
      await _service.createResume(
        baseUrl: baseUrl,
        userId: userId,
        title: title,
        resumeContentJson: contentJson,
        completionScore: completionScore ?? 70,
      );
      await loadResumes();
    });
  }

  Future<void> updateResume({
    required int resumeId,
    required String title,
    required String contentJson,
    double? completionScore,
  }) async {
    await _runBusy(() async {
      await _service.updateResume(
        baseUrl: baseUrl,
        userId: userId,
        resumeId: resumeId,
        title: title,
        resumeContentJson: contentJson,
        completionScore: completionScore ?? 70,
      );
      await loadResumes();
    });
  }

  Future<void> uploadResumeFile({
    required String filePath,
    required String fileName,
    String? title,
  }) async {
    await _runBusy(() async {
      await _service.uploadResumeFile(
        baseUrl: baseUrl,
        userId: userId,
        filePath: filePath,
        fileName: fileName,
        title: title,
      );
      await loadResumes();
    });
  }

  Future<void> setDefaultResume(int resumeId) async {
    await _runBusy(() async {
      await _service.setDefaultResume(
        baseUrl: baseUrl,
        userId: userId,
        resumeId: resumeId,
      );
      await loadResumes();
    });
  }

  Future<void> applyJob({
    required int jobId,
    required int resumeId,
  }) async {
    await _runBusy(() async {
      await _service.applyJob(
        baseUrl: baseUrl,
        userId: userId,
        jobId: jobId,
        resumeId: resumeId,
      );
      await Future.wait([
        loadApplications(),
        loadConversations(),
      ]);
    });
  }

  Future<void> loadOffers() async {
    _offers = await _service.listOffers(
      baseUrl: baseUrl,
      userId: userId,
    );
    _notifySafely();
  }

  Future<void> offerDecision({
    required int offerId,
    required String action,
    String? rejectReason,
  }) async {
    await _runBusy(() async {
      await _service.offerDecision(
        baseUrl: baseUrl,
        userId: userId,
        offerId: offerId,
        action: action,
        rejectReason: rejectReason,
      );
      await Future.wait([
        loadOffers(),
        loadApplications(),
      ]);
    });
  }

  Future<void> loadInterviews() async {
    _interviews = await _service.listInterviews(
      baseUrl: baseUrl,
      userId: userId,
    );
    final interviewIds =
        _interviews.map((item) => _toInt(item['id'])).whereType<int>().toSet();
    _interviewConfirmStates
        .removeWhere((interviewId, _) => !interviewIds.contains(interviewId));
    _notifySafely();
  }

  Map<String, dynamic>? interviewConfirmState(int interviewId) {
    return _interviewConfirmStates[interviewId];
  }

  Future<void> submitInterviewConfirmation({
    required int interviewId,
    required String action,
    String? note,
    DateTime? expectedRescheduleAt,
  }) async {
    final normalizedAction = action.trim().toLowerCase();
    if (normalizedAction != 'confirm' &&
        normalizedAction != 'reschedule' &&
        normalizedAction != 'decline') {
      throw ArgumentError('不支持的面试确认动作: $action');
    }

    _interviewConfirmStates[interviewId] = <String, dynamic>{
      'action': normalizedAction,
      'note': note?.trim(),
      'expectedRescheduleAt': expectedRescheduleAt?.toIso8601String(),
      'submittedAt': DateTime.now().toIso8601String(),
    };
    _notifySafely();
  }

  Future<void> loadReviews() async {
    _reviews = await _service.listReviews(
      baseUrl: baseUrl,
      userId: userId,
    );
    _notifySafely();
  }

  Future<void> createReview({
    required int applicationId,
    required int enterpriseId,
    required int rating,
    required String content,
  }) async {
    await _runBusy(() async {
      await _service.createReview(
        baseUrl: baseUrl,
        userId: userId,
        applicationId: applicationId,
        enterpriseId: enterpriseId,
        rating: rating,
        content: content,
      );
      await loadReviews();
    });
  }

  Future<void> loadReports() async {
    _reports = await _service.listReports(
      baseUrl: baseUrl,
      userId: userId,
    );
    _notifySafely();
  }

  Future<void> createReport({
    required int targetType,
    required int targetId,
    required String reason,
    String? evidenceUrl,
  }) async {
    await _runBusy(() async {
      await _service.createReport(
        baseUrl: baseUrl,
        userId: userId,
        targetType: targetType,
        targetId: targetId,
        reason: reason,
        evidenceUrl: evidenceUrl,
      );
      await loadReports();
    });
  }

  int? defaultResumeId() {
    for (final resume in _resumes) {
      final isDefault = (resume['isDefault'] as num?)?.toInt() == 1;
      if (isDefault) {
        return _toInt(resume['id']);
      }
    }
    return null;
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
