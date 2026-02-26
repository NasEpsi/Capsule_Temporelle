import 'package:flutter/foundation.dart';

import '../database/database_service.dart';
import '../../models/user.dart';
import '../../models/capsule.dart';

// Prévu pour sprint auth (tu as créé un dossier auth)
// import '../auth/auth_service.dart';

class DatabaseProvider extends ChangeNotifier {
  // final _auth = AuthService(); // Sprint suivant
  final DatabaseService _db = DatabaseService();

  // Token prévu sprint auth
  String _token = "";
  String get token => _token;
  void setToken(String value) {
    _token = value;
    notifyListeners();
  }

  // Etat global
  bool loading = false;
  String? error;

  // USER
  User? currentUser;

  // CAPSULES
  List<Capsule> capsules = [];
  // -------- Helpers --------
  Future<T?> _run<T>(Future<T> Function() action) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      return await action();
    } catch (e) {
      error = e.toString();
      return null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // -------- USERS --------

  Future<void> fetchUserById(int userId) async {
    await _run(() async {
      currentUser = await _db.getUserById(userId: userId, token: _token.isEmpty ? null : _token);
    });
  }

  // -------- CAPSULES --------

  Future<void> fetchCapsulesForUser(int userId) async {
    await _run(() async {
      capsules = await _db.getCapsulesForUser(userId: userId, token: _token.isEmpty ? null : _token);
    });
  }

  Future<void> createNewCapsule({
    required int creatorUserId,
    required String title,
    String? description,
    required DateTime unlockAt,
    required String requiredSky,
  }) async {
    final created = await _run(() async {
      return await _db.createCapsule(
        creatorUserId: creatorUserId,
        title: title,
        description: description,
        unlockAt: unlockAt,
        requiredSky: requiredSky,
        token: _token.isEmpty ? null : _token,
      );
    });

    if (created != null) {
      capsules = [created, ...capsules];
      notifyListeners();
    }
  }
}