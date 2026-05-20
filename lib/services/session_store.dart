import 'package:shared_preferences/shared_preferences.dart';

class SessionStore {
  static const _kLoginToken = 'login_token';
  static const _kUserId = 'user_id';
  static const _kUsername = 'username';
  static const _kEmail = 'email';
  static const _kRoleId = 'role_id';

  Future<void> saveSession({
    required String loginToken,
    required int id,
    required String username,
    required String email,
    required int roleId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLoginToken, loginToken);
    await prefs.setInt(_kUserId, id);
    await prefs.setString(_kUsername, username);
    await prefs.setString(_kEmail, email);
    await prefs.setInt(_kRoleId, roleId);
  }

  Future<String?> getLoginToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kLoginToken);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLoginToken);
    await prefs.remove(_kUserId);
    await prefs.remove(_kUsername);
    await prefs.remove(_kEmail);
    await prefs.remove(_kRoleId);
  }
}

