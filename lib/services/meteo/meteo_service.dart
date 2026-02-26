import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models/weather_snapshot.dart';
import 'mapper_meteo.dart';

class MeteoService {
  static const String _baseUrl = "https://api.open-meteo.com/v1/forecast";

  void _ensureSuccess(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("HTTP ${res.statusCode}: ${res.body}");
    }
  }

  Future<WeatherSnapshot> getCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      "latitude": latitude.toString(),
      "longitude": longitude.toString(),
      "current": "temperature_2m,weather_code",
      "timezone": "Europe/Paris",
    });

    final res = await http.get(uri);
    _ensureSuccess(res);

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final current = data["current"] as Map<String, dynamic>;

    final time = DateTime.parse(current["time"] as String);
    final temp = (current["temperature_2m"] as num).toDouble();
    final code = (current["weather_code"] as num).toInt();

    return WeatherSnapshot(
      time: time,
      temperatureC: temp,
      weatherCode: code,
      sky: mapWeatherCodeToMeteo(code),
    );
  }
}