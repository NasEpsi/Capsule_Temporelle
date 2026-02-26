import 'package:flutter/foundation.dart';
import '../../models/user.dart';
import 'auth_service.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _auth = AuthService();

  AuthStatus status = AuthStatus.loading;
  String token = "";
  User? user;

  /// à appeler au démarrage (équivalent "authStateChanges" init)
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
    } catch (_) {
      // token invalide/expiré
      await _auth.clearToken();
      token = "";
      user = null;
      status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.logout();
    token = "";
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    status = AuthStatus.loading;
    notifyListeners();

    final session = await _auth.login(email: email, password: password);
    token = session.token;
    user = session.user;
    status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> register(String name, String email, String password) async {
    status = AuthStatus.loading;
    notifyListeners();

    final session = await _auth.register(name: name, email: email, password: password);
    token = session.token;
    user = session.user;
    status = AuthStatus.authenticated;
    notifyListeners();
  }
}