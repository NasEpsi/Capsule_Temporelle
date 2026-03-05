import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../models/user.dart';

class AuthService {

  /// ⚠️ Android Emulator => 10.0.2.2
  static const String _baseUrl = "http://10.0.2.2:3000";

  static const _storage = FlutterSecureStorage();
  static const _kTokenKey = "auth_token";

  /// timeout global réseau
  static const Duration _timeout = Duration(seconds: 8);

  Map<String, String> _headers({String? token}) => {
    "Content-Type": "application/json",
    if (token != null && token.isNotEmpty)
      "Authorization": "Bearer $token",
  };

  void _ensureSuccess(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      debugPrint("HTTP ERROR ${res.statusCode} -> ${res.body}");
      throw Exception("HTTP ${res.statusCode}");
    }
  }

  // =============================
  // Local Token
  // =============================

  Future<String?> readToken() async {
    final token = await _storage.read(key: _kTokenKey);
    debugPrint("READ TOKEN => ${token != null}");
    return token;
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: _kTokenKey, value: token);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _kTokenKey);
  }

  // =============================
  // API CALLS
  // =============================

  /// Validate token + current user
  Future<User> me({required String token}) async {
    debugPrint("CALL /auth/me");

    final res = await http
        .get(
      Uri.parse("$_baseUrl/auth/me"),
      headers: _headers(token: token),
    )
        .timeout(_timeout);

    _ensureSuccess(res);

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final userJson =
    (data["user"] ?? data) as Map<String, dynamic>;

    return User.fromJson(userJson);
  }

  /// Login
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    debugPrint("CALL /auth/login");

    final res = await http
        .post(
      Uri.parse("$_baseUrl/auth/login"),
      headers: _headers(),
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    )
        .timeout(_timeout);

    _ensureSuccess(res);

    final data = jsonDecode(res.body) as Map<String, dynamic>;

    final token = data["token"] as String;
    final user =
    User.fromJson(data["user"] as Map<String, dynamic>);

    await saveToken(token);

    return AuthSession(token: token, user: user);
  }

  /// Register
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async {
    debugPrint("CALL /auth/register");

    final res = await http
        .post(
      Uri.parse("$_baseUrl/auth/register"),
      headers: _headers(),
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
      }),
    )
        .timeout(_timeout);

    _ensureSuccess(res);

    final data = jsonDecode(res.body) as Map<String, dynamic>;

    final token = data["token"] as String;
    final user =
    User.fromJson(data["user"] as Map<String, dynamic>);

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

  AuthSession({
    required this.token,
    required this.user,
  });
}