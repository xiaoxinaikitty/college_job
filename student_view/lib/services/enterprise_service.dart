import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

class EnterpriseService {
  Future<Map<String, dynamic>> profileDetail({
    required String baseUrl,
    required int userId,
  }) async {
    final data = await _request(
      method: 'GET',
      baseUrl: baseUrl,
      path: '/api/enterprise/profile',
      userId: userId,
    );
    return _asMap(data);
  }

  Future<Map<String, dynamic>> updateProfile({
    required String baseUrl,
    required int userId,
    required Map<String, dynamic> body,
  }) async {
    final data = await _request(
      method: 'PUT',
      baseUrl: baseUrl,
      path: '/api/enterprise/profile',
      userId: userId,
      body: body,
    );
    return _asMap(data);
  }

  Future<Map<String, dynamic>> submitCertification({
    required String baseUrl,
    required int userId,
    required String licenseFileUrl,
    String? submitRemark,
  }) async {
    final data = await _request(
      method: 'POST',
      baseUrl: baseUrl,
      path: '/api/enterprise/certifications/submit',
      userId: userId,
      body: {
        'licenseFileUrl': licenseFileUrl,
        'submitRemark': submitRemark,
      },
    );
    return _asMap(data);
  }

  Future<Map<String, dynamic>> createJob({
    required String baseUrl,
    required int userId,
    required Map<String, dynamic> body,
  }) async {
    final data = await _request(
      method: 'POST',
      baseUrl: baseUrl,
      path: '/api/enterprise/jobs',
      userId: userId,
      body: body,
    );
    return _asMap(data);
  }

  Future<Map<String, dynamic>> updateJob({
    required String baseUrl,
    required int userId,
    required int jobId,
    required Map<String, dynamic> body,
  }) async {
    final data = await _request(
      method: 'PUT',
      baseUrl: baseUrl,
      path: '/api/enterprise/jobs/$jobId',
      userId: userId,
      body: body,
    );
    return _asMap(data);
  }

  Future<Map<String, dynamic>> offlineJob({
    required String baseUrl,
    required int userId,
    required int jobId,
  }) async {
    final data = await _request(
      method: 'PUT',
      baseUrl: baseUrl,
      path: '/api/enterprise/jobs/$jobId/offline',
      userId: userId,
    );
    return _asMap(data);
  }

  Future<List<Map<String, dynamic>>> listJobs({
    required String baseUrl,
    required int userId,
  }) async {
    final data = await _request(
      method: 'GET',
      baseUrl: baseUrl,
      path: '/api/enterprise/jobs',
      userId: userId,
    );
    return _asMapList(data);
  }

  Future<List<Map<String, dynamic>>> listApplications({
    required String baseUrl,
    required int userId,
    int? status,
    int? jobId,
  }) async {
    final data = await _request(
      method: 'GET',
      baseUrl: baseUrl,
      path: '/api/enterprise/applications',
      userId: userId,
      query: {
        if (status != null) 'status': '$status',
        if (jobId != null) 'jobId': '$jobId',
      },
    );
    return _asMapList(data);
  }

  Future<Map<String, dynamic>> applicationDetail({
    required String baseUrl,
    required int userId,
    required int applicationId,
  }) async {
    final data = await _request(
      method: 'GET',
      baseUrl: baseUrl,
      path: '/api/enterprise/applications/$applicationId',
      userId: userId,
    );
    return _asMap(data);
  }

  Future<Map<String, dynamic>> updateApplicationStatus({
    required String baseUrl,
    required int userId,
    required int applicationId,
    required int toStatus,
    String? rejectReason,
    String? note,
  }) async {
    final data = await _request(
      method: 'POST',
      baseUrl: baseUrl,
      path: '/api/enterprise/applications/$applicationId/status',
      userId: userId,
      body: {
        'toStatus': toStatus,
        'rejectReason': rejectReason,
        'note': note,
      },
    );
    return _asMap(data);
  }

  Future<List<Map<String, dynamic>>> listChats({
    required String baseUrl,
    required int userId,
  }) async {
    final data = await _request(
      method: 'GET',
      baseUrl: baseUrl,
      path: '/api/enterprise/chats',
      userId: userId,
    );
    return _asMapList(data);
  }

  Future<List<Map<String, dynamic>>> listMessages({
    required String baseUrl,
    required int userId,
    required int conversationId,
  }) async {
    final data = await _request(
      method: 'GET',
      baseUrl: baseUrl,
      path: '/api/enterprise/chats/$conversationId/messages',
      userId: userId,
    );
    return _asMapList(data);
  }

  Future<Map<String, dynamic>> sendMessage({
    required String baseUrl,
    required int userId,
    required int conversationId,
    required int messageType,
    required String contentText,
    String? fileUrl,
  }) async {
    final data = await _request(
      method: 'POST',
      baseUrl: baseUrl,
      path: '/api/enterprise/chats/$conversationId/messages',
      userId: userId,
      body: {
        'messageType': messageType,
        'contentText': contentText,
        'fileUrl': fileUrl,
      },
    );
    return _asMap(data);
  }

  Future<Map<String, dynamic>> createInterview({
    required String baseUrl,
    required int userId,
    required Map<String, dynamic> body,
  }) async {
    final data = await _request(
      method: 'POST',
      baseUrl: baseUrl,
      path: '/api/enterprise/interviews',
      userId: userId,
      body: body,
    );
    return _asMap(data);
  }

  Future<List<Map<String, dynamic>>> listInterviews({
    required String baseUrl,
    required int userId,
    int? applicationId,
  }) async {
    final data = await _request(
      method: 'GET',
      baseUrl: baseUrl,
      path: '/api/enterprise/interviews',
      userId: userId,
      query: {
        if (applicationId != null) 'applicationId': '$applicationId',
      },
    );
    return _asMapList(data);
  }

  Future<Map<String, dynamic>> submitInterviewResult({
    required String baseUrl,
    required int userId,
    required int interviewId,
    required String result,
    String? note,
  }) async {
    final data = await _request(
      method: 'POST',
      baseUrl: baseUrl,
      path: '/api/enterprise/interviews/$interviewId/result',
      userId: userId,
      body: {
        'result': result,
        'note': note,
      },
    );
    return _asMap(data);
  }

  Future<Map<String, dynamic>> createOffer({
    required String baseUrl,
    required int userId,
    required Map<String, dynamic> body,
  }) async {
    final data = await _request(
      method: 'POST',
      baseUrl: baseUrl,
      path: '/api/enterprise/offers',
      userId: userId,
      body: body,
    );
    return _asMap(data);
  }

  Future<List<Map<String, dynamic>>> listOffers({
    required String baseUrl,
    required int userId,
  }) async {
    final data = await _request(
      method: 'GET',
      baseUrl: baseUrl,
      path: '/api/enterprise/offers',
      userId: userId,
    );
    return _asMapList(data);
  }

  Future<dynamic> _request({
    required String method,
    required String baseUrl,
    required String path,
    int? userId,
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
  }) async {
    final cleanBaseUrl = baseUrl.trim().replaceAll(RegExp(r'\/+$'), '');
    final uri = Uri.parse('$cleanBaseUrl$path').replace(
      queryParameters: query?.map((k, v) => MapEntry(k, v.toString())),
    );

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (userId != null) 'X-User-Id': '$userId',
    };

    http.Response response;
    try {
      switch (method) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: jsonEncode(body ?? const <String, dynamic>{}),
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: jsonEncode(body ?? const <String, dynamic>{}),
          );
          break;
        default:
          throw ApiException('不支持的请求方法: $method');
      }
    } catch (e) {
      throw ApiException('网络异常: $e');
    }

    Map<String, dynamic> wrapper;
    try {
      wrapper = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException('服务端响应格式错误');
    }

    final code = (wrapper['code'] as num?)?.toInt() ?? -1;
    final message = wrapper['message']?.toString() ?? '请求失败';
    if (response.statusCode < 200 || response.statusCode >= 300 || code != 0) {
      throw ApiException(message);
    }
    return wrapper['data'];
  }

  Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{};
  }

  List<Map<String, dynamic>> _asMapList(dynamic raw) {
    if (raw is! List) {
      return <Map<String, dynamic>>[];
    }
    return raw.map((item) => _asMap(item)).toList();
  }
}
