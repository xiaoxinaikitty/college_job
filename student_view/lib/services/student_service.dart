import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/paged_result.dart';
import 'api_exception.dart';

class StudentService {
  Future<List<Map<String, dynamic>>> listResumes({
    required String baseUrl,
    required int userId,
  }) async {
    final data = await _request(
      method: 'GET',
      baseUrl: baseUrl,
      path: '/api/student/resumes',
      userId: userId,
    );
    return _asMapList(data);
  }

  Future<Map<String, dynamic>> createResume({
    required String baseUrl,
    required int userId,
    required String title,
    required String resumeContentJson,
    double? completionScore,
  }) async {
    final data = await _request(
      method: 'POST',
      baseUrl: baseUrl,
      path: '/api/student/resumes',
      userId: userId,
      body: {
        'title': title,
        'resumeContentJson': resumeContentJson,
        if (completionScore != null) 'completionScore': completionScore,
      },
    );
    return _asMap(data);
  }

  Future<Map<String, dynamic>> uploadResumeFile({
    required String baseUrl,
    required int userId,
    required String filePath,
    required String fileName,
    String? title,
  }) async {
    final cleanBaseUrl = baseUrl.trim().replaceAll(RegExp(r'\/+$'), '');
    final uri = Uri.parse('$cleanBaseUrl/api/student/resumes/upload');
    final request = http.MultipartRequest('POST', uri)
      ..headers['X-User-Id'] = '$userId'
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          filePath,
          filename: fileName,
        ),
      );

    if (title != null && title.trim().isNotEmpty) {
      request.fields['title'] = title.trim();
    }

    http.StreamedResponse streamedResponse;
    http.Response response;
    try {
      streamedResponse = await request.send();
      response = await http.Response.fromStream(streamedResponse);
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

    return _asMap(wrapper['data']);
  }

  Future<Map<String, dynamic>> updateResume({
    required String baseUrl,
    required int userId,
    required int resumeId,
    required String title,
    required String resumeContentJson,
    double? completionScore,
  }) async {
    final data = await _request(
      method: 'PUT',
      baseUrl: baseUrl,
      path: '/api/student/resumes/$resumeId',
      userId: userId,
      body: {
        'title': title,
        'resumeContentJson': resumeContentJson,
        if (completionScore != null) 'completionScore': completionScore,
      },
    );
    return _asMap(data);
  }

  Future<void> setDefaultResume({
    required String baseUrl,
    required int userId,
    required int resumeId,
  }) async {
    await _request(
      method: 'PUT',
      baseUrl: baseUrl,
      path: '/api/student/resumes/$resumeId/default',
      userId: userId,
    );
  }

  Future<PagedResult<Map<String, dynamic>>> listJobs({
    required String baseUrl,
    String? keyword,
    String? city,
    String? category,
    int page = 0,
    int size = 10,
  }) async {
    final data = await _request(
      method: 'GET',
      baseUrl: baseUrl,
      path: '/api/student/jobs',
      query: {
        if (keyword != null && keyword.trim().isNotEmpty) 'keyword': keyword,
        if (city != null && city.trim().isNotEmpty) 'city': city,
        if (category != null && category.trim().isNotEmpty)
          'category': category,
        'page': '$page',
        'size': '$size',
      },
    );
    return PagedResult.fromJson(
      _asMap(data),
      (raw) => _asMap(raw),
    );
  }

  Future<Map<String, dynamic>> jobDetail({
    required String baseUrl,
    required int jobId,
  }) async {
    final data = await _request(
      method: 'GET',
      baseUrl: baseUrl,
      path: '/api/student/jobs/$jobId',
    );
    return _asMap(data);
  }

  Future<Map<String, dynamic>> applyJob({
    required String baseUrl,
    required int userId,
    required int jobId,
    required int resumeId,
  }) async {
    final data = await _request(
      method: 'POST',
      baseUrl: baseUrl,
      path: '/api/student/applications',
      userId: userId,
      body: {
        'jobId': jobId,
        'resumeId': resumeId,
      },
    );
    return _asMap(data);
  }

  Future<List<Map<String, dynamic>>> listApplications({
    required String baseUrl,
    required int userId,
  }) async {
    final data = await _request(
      method: 'GET',
      baseUrl: baseUrl,
      path: '/api/student/applications',
      userId: userId,
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
      path: '/api/student/applications/$applicationId',
      userId: userId,
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
      path: '/api/student/chats',
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
      path: '/api/student/chats/$conversationId/messages',
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
      path: '/api/student/chats/$conversationId/messages',
      userId: userId,
      body: {
        'messageType': messageType,
        'contentText': contentText,
        'fileUrl': fileUrl,
      },
    );
    return _asMap(data);
  }

  Future<List<Map<String, dynamic>>> listInterviews({
    required String baseUrl,
    required int userId,
  }) async {
    final data = await _request(
      method: 'GET',
      baseUrl: baseUrl,
      path: '/api/student/interviews',
      userId: userId,
    );
    return _asMapList(data);
  }

  Future<List<Map<String, dynamic>>> listOffers({
    required String baseUrl,
    required int userId,
  }) async {
    final data = await _request(
      method: 'GET',
      baseUrl: baseUrl,
      path: '/api/student/offers',
      userId: userId,
    );
    return _asMapList(data);
  }

  Future<Map<String, dynamic>> offerDecision({
    required String baseUrl,
    required int userId,
    required int offerId,
    required String action,
    String? rejectReason,
  }) async {
    final data = await _request(
      method: 'POST',
      baseUrl: baseUrl,
      path: '/api/student/offers/$offerId/decision',
      userId: userId,
      body: {
        'action': action,
        'rejectReason': rejectReason,
      },
    );
    return _asMap(data);
  }

  Future<Map<String, dynamic>> createReview({
    required String baseUrl,
    required int userId,
    required int applicationId,
    required int enterpriseId,
    required int rating,
    required String content,
  }) async {
    final data = await _request(
      method: 'POST',
      baseUrl: baseUrl,
      path: '/api/student/reviews',
      userId: userId,
      body: {
        'applicationId': applicationId,
        'enterpriseId': enterpriseId,
        'rating': rating,
        'content': content,
      },
    );
    return _asMap(data);
  }

  Future<List<Map<String, dynamic>>> listReviews({
    required String baseUrl,
    required int userId,
  }) async {
    final data = await _request(
      method: 'GET',
      baseUrl: baseUrl,
      path: '/api/student/reviews',
      userId: userId,
    );
    return _asMapList(data);
  }

  Future<Map<String, dynamic>> createReport({
    required String baseUrl,
    required int userId,
    required int targetType,
    required int targetId,
    required String reason,
    String? evidenceUrl,
  }) async {
    final data = await _request(
      method: 'POST',
      baseUrl: baseUrl,
      path: '/api/student/reports',
      userId: userId,
      body: {
        'targetType': targetType,
        'targetId': targetId,
        'reason': reason,
        'evidenceUrl': evidenceUrl,
      },
    );
    return _asMap(data);
  }

  Future<List<Map<String, dynamic>>> listReports({
    required String baseUrl,
    required int userId,
  }) async {
    final data = await _request(
      method: 'GET',
      baseUrl: baseUrl,
      path: '/api/student/reports',
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
      return raw.map(
        (key, value) => MapEntry(key.toString(), value),
      );
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
