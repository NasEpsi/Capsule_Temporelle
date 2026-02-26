import 'package:flutter/material.dart';

enum WeatherCondition { sun, rain, snow, storm, cloudy, fog }

class MyChronologyCard extends StatelessWidget {
  final DateTime createdAt;
  final DateTime unlockAt;
  final WeatherCondition condition;

  const MyChronologyCard({
    super.key,
    required this.createdAt,
    required this.unlockAt,
    required this.condition,
  });

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF8D28);

    final now = DateTime.now();
    final bool isUnlocked = !unlockAt.isAfter(now);
    final Duration remaining = unlockAt.difference(now);

    String formatDateFr(DateTime date) {
      const months = ["Janvier","Février","Mars","Avril","Mai","Juin","Juillet","Août","Septembre","Octobre","Novembre","Décembre"];
      final d = date.day.toString().padLeft(2, '0');
      final m = months[date.month - 1];
      final y = date.year.toString();
      return "$d $m $y";
    }

    String remainingLabel(Duration d) {
      if (d.isNegative || d.inSeconds == 0) return "Déjà disponible";
      if (d.inMinutes < 60) return "Dans ${d.inMinutes} min";
      if (d.inHours < 24) return "Dans ${d.inHours} h";
      return "Dans ${d.inDays} jours";
    }

    IconData weatherIcon(WeatherCondition c) {
      switch (c) {
        case WeatherCondition.sun:
          return Icons.wb_sunny_outlined;
        case WeatherCondition.rain:
          return Icons.umbrella_outlined;
        case WeatherCondition.snow:
          return Icons.ac_unit;
        case WeatherCondition.cloudy:
          return Icons.cloud_outlined;
      }
    }

    final IconData conditionIcon = weatherIcon(condition);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Chronologie",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 20, color: Colors.black),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Création",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withOpacity(0.60),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatDateFr(createdAt),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 20, color: Colors.black),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Débloqué",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withOpacity(0.60),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatDateFr(unlockAt),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // temps restant (si pas débloqué)
                    if (!isUnlocked)
                      Text(
                        remainingLabel(remaining),
                        style: const TextStyle(
                          fontSize: 14,
                          color: orange,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                  ],
                ),
              ),

              // météo (à droite)
              Icon(
                conditionIcon,
                color: orange,
                size: 40,
              ),
            ],
          ),
        ],
      ),
    );
  }
}