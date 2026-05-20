class UserSession {
  UserSession({
    required this.id,
    required this.username,
    required this.email,
    required this.roleId,
    required this.loginToken,
  });

  final int id;
  final String username;
  final String email;
  final int roleId;
  final String loginToken;

  factory UserSession.fromJson(Map<String, dynamic> json) {
    final token =
        (json['login_token'] ?? json['login-token'] ?? json['token'] ?? '')
            .toString();
    return UserSession(
      id: (json['id'] as num).toInt(),
      username: (json['username'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      roleId: (json['role_id'] as num).toInt(),
      loginToken: token,
    );
  }
}

