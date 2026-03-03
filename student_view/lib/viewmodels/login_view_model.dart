import 'package:flutter/material.dart';

import '../models/account_role.dart';
import '../models/auth_payload.dart';
import '../services/auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({
    required String baseUrl,
    required AccountRole role,
  })  : _baseUrl = baseUrl,
        _role = role;

  String _phone = '';
  String _password = '';
  String _baseUrl;
  AccountRole _role;
  bool _isLoading = false;
  bool _showApiSettings = false;
  bool _obscurePassword = true;

  String get phone => _phone;
  String get password => _password;
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
      return await service.login(
        baseUrl: _baseUrl,
        phone: _phone,
        password: _password,
        userType: _role.userType,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
