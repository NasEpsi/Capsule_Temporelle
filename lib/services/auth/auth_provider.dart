import 'package:flutter/foundation.dart';
import '../../models/user.dart';
import 'auth_service.dart';
import '../database/database_service.dart';
import 'dart:async';

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _auth = AuthService();
  final DatabaseService _db = DatabaseService();

  AuthStatus status = AuthStatus.loading;
  String token = "";
  User? user;

  Future<void> init() async {
    status = AuthStatus.loading;
    notifyListeners();

    final stored = await _auth.readToken();

    if (stored == null || stored.isEmpty) {
      token = "";
      user = null;
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    try {
      final me = await _auth.me(token: stored);

      token = stored;
      user = me;
      status = AuthStatus.authenticated;
      notifyListeners();

      try {
        await _db.syncInvites(token: token);
      } catch (e) {
        debugPrint("syncInvites failed (ignored): $e");
      }
    } catch (e) {
      await _auth.clearToken();
      token = "";
      user = null;
      status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }


  Future<void> login(String email, String password) async {
    status = AuthStatus.loading;
    notifyListeners();

    try {
      final session = await _auth.login(email: email, password: password);

      token = session.token;
      user = session.user;
      status = AuthStatus.authenticated;
      notifyListeners();
      try {
        await _db.syncInvites(token: token);
      } catch (_) {}
    } catch (e) {
      token = "";
      user = null;
      status = AuthStatus.unauthenticated;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> register(String name, String email, String password) async {
    status = AuthStatus.loading;
    notifyListeners();
    try {
      final session = await _auth.register(name: name, email: email, password: password);

      token = session.token;
      user = session.user;
      status = AuthStatus.authenticated;
      notifyListeners();

      try {
        await _db.syncInvites(token: token);
      } catch (_) {}
    } catch (e) {
      token = "";
      user = null;
      status = AuthStatus.unauthenticated;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.clearToken(); 
    token = "";
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}