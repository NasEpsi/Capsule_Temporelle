import 'package:flutter/material.dart';

enum WeatherType { sun, rain, cloudy, snow }

class WeatherSquare extends StatelessWidget {
  final WeatherType type;
  final bool isActive;
  final VoidCallback onTap;

  const WeatherSquare({
    super.key,
    required this.type,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF8D28);

    IconData getIcon() {
      switch (type) {
        case WeatherType.sun:
          return Icons.wb_sunny_outlined;
        case WeatherType.rain:
          return Icons.umbrella_outlined;
        case WeatherType.cloudy:
          return Icons.cloud_outlined;
        case WeatherType.snow:
          return Icons.ac_unit;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFFF8D28).withOpacity(0.15) // actif
              : const Color(0xFFFFFFFF), // inactif
          borderRadius: BorderRadius.circular(25),
          border: isActive
              ? Border.all(color: orange, width: 1.5)
              : Border.all(color: black.withOpacity(0.1), width: 1.5),
          boxShadow: [
            if (isActive)
              BoxShadow(
                color: orange.withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
          ],
        ),
        child: Icon(
          getIcon(),
          size: 48,
          color: Colors.black,
        ),
      ),
    );
  }
}