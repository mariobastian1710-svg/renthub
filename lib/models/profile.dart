class Profile {
  Profile({
    required this.id,
    required this.username,
    required this.email,
    required this.roleId,
    required this.profilePictureUrl,
    required this.createdAt,
  });

  final int id;
  final String username;
  final String email;
  final int roleId;
  final String profilePictureUrl;
  final String createdAt;

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: (json['id'] as num).toInt(),
      username: (json['username'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      roleId: (json['role_id'] as num).toInt(),
      profilePictureUrl: (json['profile_picture_url'] ?? '').toString(),
      createdAt: (json['created_at'] ?? '').toString(),
    );
  }
}

