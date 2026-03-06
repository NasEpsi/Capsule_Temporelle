import '../../models/meteo.dart';

Meteo mapWeatherCodeToMeteo(int code) {
  // Sunny
  if (code == 0 || code == 1 || code == 2 || code == 3) return Meteo.sunny;

  // Cloudy + fog
  if (code == 45 || code == 48) return Meteo.cloudy;

  // Snow
  if ((code >= 71 && code <= 77) || code == 85 || code == 86) return Meteo.snowy;

  // Rain + drizzle + showers + thunderstorm
  if ((code >= 51 && code <= 67) || (code >= 80 && code <= 82) || (code >= 95 && code <= 99)) {
    return Meteo.rainy;
  }

  return Meteo.cloudy;
}