import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../models/user.dart';

class AuthService {
  static const String _baseUrl = "http://10.0.2.2:3000";

  static const _storage = FlutterSecureStorage();
  static const _kTokenKey = "auth_token";

  Map<String, String> _headers({String? token}) => {
    "Content-Type": "application/json",
    if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
  };

  void _ensureSuccess(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("HTTP ${res.statusCode}: ${res.body}");
    }
  }

  //Local token
  Future<String?> readToken() => _storage.read(key: _kTokenKey);
  Future<void> saveToken(String token) => _storage.write(key: _kTokenKey, value: token);
  Future<void> clearToken() => _storage.delete(key: _kTokenKey);

  // -------- API calls --------

  /// Validate token + get current user
  Future<User> me({required String token}) async {
    final res = await http.get(
      Uri.parse("$_baseUrl/auth/me"),
      headers: _headers(token: token),
    );
    _ensureSuccess(res);

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final userJson = (data["user"] ?? data) as Map<String, dynamic>;
    return User.fromJson(userJson);
  }

  /// Login -> returns token + user
  Future<AuthSession> login({required String email, required String password}) async {
    final res = await http.post(
      Uri.parse("$_baseUrl/auth/login"),
      headers: _headers(),
      body: jsonEncode({"email": email, "password": password}),
    );
    _ensureSuccess(res);

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final token = data["token"] as String;
    final user = User.fromJson(data["user"] as Map<String, dynamic>);
    await saveToken(token);
    return AuthSession(token: token, user: user);
  }

  /// Register -> (on le garde mais tu ajusteras quand tu me donneras les précisions)
  Future<AuthSession> register({required String name, required String email, required String password}) async {
    final res = await http.post(
      Uri.parse("$_baseUrl/auth/register"),
      headers: _headers(),
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );
    _ensureSuccess(res);

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final token = data["token"] as String;
    final user = User.fromJson(data["user"] as Map<String, dynamic>);
    await saveToken(token);
    return AuthSession(token: token, user: user);
  }

  Future<void> logout() async {
    await clearToken();
  }
}

class AuthSession {
  final String token;
  final User user;
  AuthSession({required this.token, required this.user});
}