import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/auth_payload.dart';
import 'api_exception.dart';

class AuthService {
  Future<AuthPayload> login({
    required String baseUrl,
    required String phone,
    required String password,
    required int userType,
  }) {
    return _post(
      baseUrl: baseUrl,
      path: '/api/auth/login',
      body: {
        'phone': phone,
        'password': password,
        'userType': userType,
      },
    );
  }

  Future<AuthPayload> registerStudent({
    required String baseUrl,
    required String phone,
    required String password,
    String? nickname,
  }) {
    return _post(
      baseUrl: baseUrl,
      path: '/api/auth/register/student',
      body: {
        'phone': phone,
        'password': password,
        if (nickname != null && nickname.isNotEmpty) 'nickname': nickname,
      },
    );
  }

  Future<AuthPayload> registerEnterprise({
    required String baseUrl,
    required String phone,
    required String password,
    required String enterpriseName,
    String? unifiedCreditCode,
  }) {
    return _post(
      baseUrl: baseUrl,
      path: '/api/auth/register/enterprise',
      body: {
        'phone': phone,
        'password': password,
        'enterpriseName': enterpriseName,
        if (unifiedCreditCode != null && unifiedCreditCode.isNotEmpty)
          'unifiedCreditCode': unifiedCreditCode,
      },
    );
  }

  Future<AuthPayload> _post({
    required String baseUrl,
    required String path,
    required Map<String, dynamic> body,
  }) async {
    final url = Uri.parse('${baseUrl.trim()}$path');
    http.Response response;

    try {
      response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
    } catch (e) {
      throw ApiException('网络异常: $e');
    }

    Map<String, dynamic> jsonBody;
    try {
      jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException('服务端响应格式错误');
    }

    final code = jsonBody['code'] as int? ?? -1;
    final message = jsonBody['message']?.toString() ?? '请求失败';
    if (response.statusCode < 200 || response.statusCode >= 300 || code != 0) {
      throw ApiException(message);
    }

    final data = jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw ApiException('响应数据缺失');
    }

    return AuthPayload.fromJson(data);
  }
}
