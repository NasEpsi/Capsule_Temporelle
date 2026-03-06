import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import '../database/database_service.dart';
import '../../models/user.dart';
import '../../models/capsule.dart';
import '../../models/weather_snapshot.dart';
import '../meteo/meteo_service.dart';
import '../../helper/constants.dart';

class DatabaseProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

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

  // METEO
  final MeteoService _meteo = MeteoService();
  WeatherSnapshot? currentWeather;

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



  //USERS
  Future<void> fetchUserById(int userId) async {
    await _run(() async {
      currentUser = await _db.getUserById(
        userId: userId,
        token: _token.isEmpty ? null : _token,
      );
    });
  }

  //CAPSULES

  Future<void> fetchCapsulesForUser(int userId) async {
    await _run(() async {
      capsules = await _db.getCapsulesForUser(
        userId: userId,
        token: _token.isEmpty ? null : _token,
      );
    });
  }

  Future<void> fetchMyCapsules() async {
  if (loading) return;
  final u = currentUser;
  if (u == null) {
    error = "Utilisateur non chargé";
    notifyListeners();
    return;
  }

  if (_token.isEmpty) {
    error = "User not authenticated";
    notifyListeners();
    return;
  }

  await _run(() async {
    await _db.syncInvites(token: _token);
    capsules = await _db.getCapsulesForUser(
      userId: u.id,
      token: _token,
    );
  });
}

  Future<Capsule?> createCapsule({
    required String title,
    String? description,
    required DateTime unlockAt,
    required String requiredSky,
    String? beneficiaryEmail,
    }) async {
      if (_token.isEmpty) throw Exception("User not authenticated");

      final created = await _run(() async {
        return await _db.createCapsule(
          token: _token,
          title: title,
          description: description,
          unlockAt: unlockAt,
          requiredSky: requiredSky,
          beneficiaryEmail: beneficiaryEmail,
        );
      });

    if (created != null) {
      capsules = [created, ...capsules];
      notifyListeners();
    }
    return created;
  }

  Future<void> addMember({
    required int capsuleId,
    String? beneficiaryEmail,
    required List<String> contributorEmails,
    }) async {
      if (_token.isEmpty) throw Exception("User not authenticated");

      await _run(() async {
        await _db.addMember(
          token: _token,
          capsuleId: capsuleId,
          beneficiaryEmail: beneficiaryEmail,
          contributorEmails: contributorEmails,
        );
      });
      await fetchMyCapsules();
  }

  // METEO
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

  Future<void> logout(BuildContext context) async {
    _token = "";
    currentUser = null;
    capsules = [];
    error = null;

    notifyListeners();

    Navigator.of(context).pushNamedAndRemoveUntil(
      "/login",
          (route) => false,
    );
  }
}