import 'package:rental_marketplace/models/user_session.dart';
import 'package:rental_marketplace/services/api_client.dart';

class AuthService {
  AuthService({required this.api});

  final ApiClient api;

  Future<UserSession> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final json = await api.postJson(
      '/register',
      body: {
        'username': username,
        'email': email,
        'password': password,
      },
    );
    return UserSession.fromJson(json);
  }

  Future<UserSession> login({
    required String username,
    required String password,
  }) async {
    final json = await api.postJson(
      '/login',
      body: {
        'username': username,
        'password': password,
      },
    );
    return UserSession.fromJson(json);
  }

  Future<void> logout({required String loginToken}) async {
    await api.postJson('/logout', loginToken: loginToken);
  }
}

