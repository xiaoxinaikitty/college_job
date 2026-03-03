import '../models/account_role.dart';
import '../models/auth_payload.dart';

class LoginRouteArgs {
  LoginRouteArgs({
    required this.baseUrl,
    required this.role,
  });

  final String baseUrl;
  final AccountRole role;
}

class RegisterRouteArgs {
  RegisterRouteArgs({
    required this.baseUrl,
    required this.role,
  });

  final String baseUrl;
  final AccountRole role;
}

class DashboardRouteArgs {
  DashboardRouteArgs({
    required this.payload,
    required this.baseUrl,
  });

  final AuthPayload payload;
  final String baseUrl;

  AccountRole get role => payload.userType == AccountRole.enterprise.userType
      ? AccountRole.enterprise
      : AccountRole.student;
}
