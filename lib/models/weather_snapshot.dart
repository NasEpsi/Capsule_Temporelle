import 'meteo.dart';

class WeatherSnapshot {
  final DateTime time;
  final double temperatureC;
  final int weatherCode;
  final Meteo sky;

  WeatherSnapshot({
    required this.time,
    required this.temperatureC,
    required this.weatherCode,
    required this.sky,
  });
}