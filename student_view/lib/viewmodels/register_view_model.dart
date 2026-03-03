import 'package:flutter/material.dart';

import '../models/account_role.dart';
import '../models/auth_payload.dart';
import '../services/auth_service.dart';

class RegisterViewModel extends ChangeNotifier {
  RegisterViewModel({
    required String baseUrl,
    required AccountRole role,
  })  : _baseUrl = baseUrl,
        _role = role;

  String _phone = '';
  String _password = '';
  String _nickname = '';
  String _enterpriseName = '';
  String _creditCode = '';
  String _baseUrl;
  AccountRole _role;
  bool _isLoading = false;
  bool _showApiSettings = false;
  bool _obscurePassword = true;

  String get phone => _phone;
  String get password => _password;
  String get nickname => _nickname;
  String get enterpriseName => _enterpriseName;
  String get creditCode => _creditCode;
  String get baseUrl => _baseUrl;
  AccountRole get role => _role;
  bool get isLoading => _isLoading;
  bool get showApiSettings => _showApiSettings;
  bool get obscurePassword => _obscurePassword;

  set phone(String value) {
    _phone = value;
  }

  set password(String value) {
    _password = value;
  }

  set nickname(String value) {
    _nickname = value;
  }

  set enterpriseName(String value) {
    _enterpriseName = value;
  }

  set creditCode(String value) {
    _creditCode = value;
  }

  set baseUrl(String value) {
    _baseUrl = value;
  }

  void setRole(AccountRole value) {
    _role = value;
    notifyListeners();
  }

  void toggleApiSettings() {
    _showApiSettings = !_showApiSettings;
    notifyListeners();
  }

  void toggleObscurePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  Future<AuthPayload> submit(AuthService service) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_role == AccountRole.student) {
        return await service.registerStudent(
          baseUrl: _baseUrl,
          phone: _phone,
          password: _password,
          nickname: _nickname.trim().isEmpty ? null : _nickname.trim(),
        );
      }
      return await service.registerEnterprise(
        baseUrl: _baseUrl,
        phone: _phone,
        password: _password,
        enterpriseName: _enterpriseName,
        unifiedCreditCode:
            _creditCode.trim().isEmpty ? null : _creditCode.trim(),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
