import 'package:rental_marketplace/models/profile.dart';
import 'package:rental_marketplace/services/api_client.dart';

class ProfileService {
  ProfileService({required this.api});

  final ApiClient api;

  Future<Profile> getProfile({required String loginToken}) async {
    final json = await api.postJson(
      '/profile',
      loginToken: loginToken,
      body: const <String, dynamic>{},
    );
    return Profile.fromJson(json);
  }

  Future<Profile> updateProfile({
    required String loginToken,
    String? username,
    String? email,
    String? password,
    String? profilePictureUrl,
  }) async {
    final body = <String, dynamic>{};
    if (username != null && username.isNotEmpty) body['username'] = username;
    if (email != null && email.isNotEmpty) body['email'] = email;
    if (password != null && password.isNotEmpty) body['password'] = password;
    if (profilePictureUrl != null && profilePictureUrl.isNotEmpty) {
      body['profile_picture_url'] = profilePictureUrl;
    }

    final json = await api.postJson(
      '/profile/update',
      loginToken: loginToken,
      body: body,
    );

    // Backend spec response for update only returns subset fields,
    // so we refresh with /profile for a complete view.
    if (!json.containsKey('role_id') || !json.containsKey('created_at')) {
      return getProfile(loginToken: loginToken);
    }

    return Profile.fromJson(json);
  }
}

