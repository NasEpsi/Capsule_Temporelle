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

  // USERS

  Future<User> getUserById({required int userId, String? token}) async {
    final res = await http.get(
      Uri.parse("$_baseUrl/users/$userId"),
      headers: _headers(token: token),
    );
    _ensureSuccess(res);
    return User.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  // CAPSULES
  Future<Capsule> createCapsule({
    required String token,
    required String title,
    String? description,
    required DateTime unlockAt,
    required String requiredSky,
    String? beneficiaryEmail,
  }) async {
    final res = await http.post(
      Uri.parse("$_baseUrl/capsules"),
      headers: _headers(token: token),
      body: jsonEncode({
        "title": title.trim(),
        "description": (description?.trim().isEmpty ?? true) ? null : description!.trim(),
        "unlockAt": unlockAt.toUtc().toIso8601String(),
        "requiredSky": requiredSky.trim().toUpperCase(),
        "beneficiaryEmail": (beneficiaryEmail?.trim().isEmpty ?? true)
            ? null
            : beneficiaryEmail!.trim().toLowerCase(),
      }),
    );

    _ensureSuccess(res);

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    return Capsule.fromJson(decoded);
  }

  /// Capsules liées à un user (owner/beneficiary/contributor)
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

  /// Ajouter un membre à une capsule (BENEFICIARY / CONTRIBUTOR)
  Future<void> addMember({
    required String token,
    required int capsuleId,
    String? beneficiaryEmail,
    required List<String> contributorEmails,
  }) async {
    final res = await http.post(
      Uri.parse("$_baseUrl/capsules/$capsuleId/invites"),
      headers: _headers(token: token),
      body: jsonEncode({
        "beneficiaryEmail": (beneficiaryEmail?.trim().isEmpty ?? true)
            ? null
            : beneficiaryEmail!.trim().toLowerCase(),
        "contributorEmails": contributorEmails
            .map((e) => e.trim().toLowerCase())
            .where((e) => e.isNotEmpty)
            .toList(),
      }),
    );
    _ensureSuccess(res);
  }

  Future<List<Map<String, dynamic>>> getMyPendingInvites({required String token}) async {
    final res = await http.get(
      Uri.parse("$_baseUrl/invites/me"),
      headers: _headers(token: token),
    );
    _ensureSuccess(res);
    return (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
  }

  Future<void> acceptInvite({required String token, required String inviteToken}) async {
    final res = await http.post(
      Uri.parse("$_baseUrl/invites/$inviteToken/accept"),
      headers: _headers(token: token),
    );
    _ensureSuccess(res);
  }

  Future<void> autoAcceptMyInvites({required String token}) async {
    final invites = await getMyPendingInvites(token: token);
    for (final inv in invites) {
      final t = (inv["token"] ?? "").toString();
      if (t.isNotEmpty) {
        await acceptInvite(token: token, inviteToken: t);
      }
    }
  }

  Future<void> syncInvites({required String token}) async {
    final res = await http
        .post(
      Uri.parse("$_baseUrl/invites/sync"),
      headers: _headers(token: token),
    )
        .timeout(const Duration(seconds: 10));

    _ensureSuccess(res);
  }

}