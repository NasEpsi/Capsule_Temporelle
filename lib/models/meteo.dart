enum Meteo { sunny, cloudy, rainy, snowy }

extension Meteos on Meteo {
  String get labelFr {
    switch (this) {
      case Meteo.sunny:
        return "ensoleillé";
      case Meteo.cloudy:
        return "nuageux";
      case Meteo.rainy:
        return "pluvieux";
      case Meteo.snowy:
        return "neigeux";
    }
  }

  String get apiValue {
    switch (this) {
      case Meteo.sunny:
        return "SUNNY";
      case Meteo.cloudy:
        return "CLOUDY";
      case Meteo.rainy:
        return "RAINY";
      case Meteo.snowy:
        return "SNOWY";
    }
  }
}