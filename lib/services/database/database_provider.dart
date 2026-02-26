import 'package:flutter/foundation.dart';

import '../database/database_service.dart';
import '../../models/user.dart';
import '../../models/capsule.dart';

import '../../models/weather_snapshot.dart';
import '../meteo/meteo_service.dart';
import '../../helper/constants.dart';

class DatabaseProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  // Token (sync via ProxyProvider dans main.dart)
  String _token = "";
  String get token => _token;

  void setToken(String value) {
    _token = value;
    notifyListeners();
  }

  // Etat global
  bool loading = false;
  String? error;

  // USER (sync via main.dart: db.currentUser = auth.user)
  User? currentUser;

  // CAPSULES
  List<Capsule> capsules = [];

  // METEO
  final MeteoService _meteo = MeteoService();
  WeatherSnapshot? currentWeather;

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
      currentUser = await _db.getUserById(
        userId: userId,
        token: _token.isEmpty ? null : _token,
      );
    });
  }

  // -------- CAPSULES --------

  Future<void> fetchCapsulesForUser(int userId) async {
    await _run(() async {
      capsules = await _db.getCapsulesForUser(
        userId: userId,
        token: _token.isEmpty ? null : _token,
      );
    });
  }

  /// Pratique : charge les capsules du user connecté
  Future<void> fetchMyCapsules() async {
    final u = currentUser;
    if (u == null) {
      error = "Utilisateur non chargé";
      notifyListeners();
      return;
    }
    await fetchCapsulesForUser(u.id);
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

  Future<void> addMember({
    required int capsuleId,
    required int userId,
    required String role, // BENEFICIARY / CONTRIBUTOR
  }) async {
    await _run(() async {
      await _db.addMemberToCapsule(
        capsuleId: capsuleId,
        userId: userId,
        role: role,
        token: _token.isEmpty ? null : _token,
      );
    });
  }

  // -------- METEO --------

  Future<void> fetchWeatherAuxerre() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      currentWeather = await _meteo.getCurrentWeather(
        latitude: GeoDefaults.auxerreLat,
        longitude: GeoDefaults.auxerreLon,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}