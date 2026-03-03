enum AccountRole {
  student,
  enterprise,
}

extension AccountRoleExt on AccountRole {
  int get userType {
    switch (this) {
      case AccountRole.student:
        return 1;
      case AccountRole.enterprise:
        return 2;
    }
  }

  String get label {
    switch (this) {
      case AccountRole.student:
        return '学生';
      case AccountRole.enterprise:
        return '企业';
    }
  }
}
