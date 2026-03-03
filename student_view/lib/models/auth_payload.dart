class AuthPayload {
  AuthPayload({
    required this.userId,
    required this.userType,
    required this.enterpriseId,
    required this.nickname,
    required this.accessToken,
    required this.expiresIn,
  });

  final int userId;
  final int userType;
  final int? enterpriseId;
  final String nickname;
  final String accessToken;
  final int expiresIn;

  factory AuthPayload.fromJson(Map<String, dynamic> json) {
    final nicknameText = json['nickname']?.toString().trim();
    return AuthPayload(
      userId: (json['userId'] as num).toInt(),
      userType: (json['userType'] as num).toInt(),
      enterpriseId: (json['enterpriseId'] as num?)?.toInt(),
      nickname: (nicknameText != null && nicknameText.isNotEmpty)
          ? nicknameText
          : '同学',
      accessToken: json['accessToken']?.toString() ?? '',
      expiresIn: (json['expiresIn'] as num?)?.toInt() ?? 0,
    );
  }
}
