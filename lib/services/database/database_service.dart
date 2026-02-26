import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models/user.dart';
import '../../models/capsule.dart';

class DatabaseService {
  static const String _baseUrl = "http://10.0.2.2:3000";

  Map<String, String> _headers({String? token}) => {
    "Content-Type": "application/json",
    if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
  };

  void _ensureSuccess(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("HTTP ${res.statusCode}: ${res.body}");
    }
  }

  // ---------- USERS (Sprint 1) ----------

  Future<User> getUserById({required int userId, String? token}) async {
    final res = await http.get(
      Uri.parse("$_baseUrl/users/$userId"),
      headers: _headers(token: token),
    );
    _ensureSuccess(res);
    return User.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  // ---------- CAPSULES ----------

  Future<Capsule> createCapsule({
    String? token,
    required int creatorUserId,
    required String title,
    String? description,
    required DateTime unlockAt,
    required String requiredSky,
  }) async {
    final res = await http.post(
      Uri.parse("$_baseUrl/capsules"),
      headers: _headers(token: token),
      body: jsonEncode({
        "creator_user_id": creatorUserId,
        "title": title,
        "description": description,
        "unlock_at": unlockAt.toIso8601String(),
        "required_sky": requiredSky,
      }),
    );
    _ensureSuccess(res);
    return Capsule.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<List<Capsule>> getCapsulesForUser({
    String? token,
    required int userId,
  }) async {
    final res = await http.get(
      Uri.parse("$_baseUrl/users/$userId/capsules"),
      headers: _headers(token: token),
    );
    _ensureSuccess(res);

    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((e) => Capsule.fromJson(e as Map<String, dynamic>)).toList();
  }
}