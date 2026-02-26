import '../../models/sky_state.dart';

SkyState mapWeatherCodeToSkyState(int code) {
  // Sunny
  if (code == 0 || code == 1) return SkyState.sunny;

  // Cloudy + fog
  if (code == 2 || code == 3 || code == 45 || code == 48) return SkyState.cloudy;

  // Snow
  if ((code >= 71 && code <= 77) || code == 85 || code == 86) return SkyState.snowy;

  // Rain + drizzle + showers + thunderstorm
  if ((code >= 51 && code <= 67) || (code >= 80 && code <= 82) || (code >= 95 && code <= 99)) {
    return SkyState.rainy;
  }

  // Fallback : plutôt nuageux (safe)
  return SkyState.cloudy;
}