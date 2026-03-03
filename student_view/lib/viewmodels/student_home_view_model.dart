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

  void setTabIndex(int index) {
    _tabIndex = index;
    notifyListeners();
  }

  Future<void> bootstrap() async {
    _initialLoading = true;
    notifyListeners();
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
      notifyListeners();
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
    notifyListeners();
  }

  Future<Map<String, dynamic>> jobDetail(int jobId) {
    return _service.jobDetail(baseUrl: baseUrl, jobId: jobId);
  }

  Future<void> loadApplications() async {
    _applications = await _service.listApplications(
      baseUrl: baseUrl,
      userId: userId,
    );
    notifyListeners();
  }

  Future<Map<String, dynamic>> applicationDetail(int applicationId) {
    return _service.applicationDetail(
      baseUrl: baseUrl,
      userId: userId,
      applicationId: applicationId,
    );
  }

  Future<void> loadConversations() async {
    _conversations = await _service.listChats(
      baseUrl: baseUrl,
      userId: userId,
    );
    notifyListeners();
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
    notifyListeners();
  }

  Future<void> createResume({
    required String title,
    required String contentJson,
  }) async {
    await _runBusy(() async {
      await _service.createResume(
        baseUrl: baseUrl,
        userId: userId,
        title: title,
        resumeContentJson: contentJson,
        completionScore: 70,
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
    notifyListeners();
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
    notifyListeners();
  }

  Future<void> loadReviews() async {
    _reviews = await _service.listReviews(
      baseUrl: baseUrl,
      userId: userId,
    );
    notifyListeners();
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
    notifyListeners();
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
    notifyListeners();
    try {
      await action();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
