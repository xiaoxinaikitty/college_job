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

  void setTabIndex(int index) {
    _tabIndex = index;
    notifyListeners();
  }

  Future<void> bootstrap() async {
    _initialLoading = true;
    notifyListeners();
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
      notifyListeners();
    }
  }

  Future<void> loadProfile() async {
    _profile = await _service.profileDetail(baseUrl: baseUrl, userId: userId);
    notifyListeners();
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
    notifyListeners();
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
    notifyListeners();
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
    _conversations = await _service.listChats(baseUrl: baseUrl, userId: userId);
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

  Future<void> loadInterviews({int? applicationId}) async {
    _interviews = await _service.listInterviews(
      baseUrl: baseUrl,
      userId: userId,
      applicationId: applicationId,
    );
    notifyListeners();
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
    notifyListeners();
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
    notifyListeners();
    try {
      await action();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
