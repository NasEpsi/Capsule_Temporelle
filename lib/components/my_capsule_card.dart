import 'package:flutter/material.dart';

enum CapsuleStatus { preparing, locked, unlocked }

class MyCapsuleCard extends StatelessWidget {
  final String title;
  final CapsuleStatus status;

  // Ouvre dans n jours
  final int? opensInDays;

  // Date de déblocage (si unlocked)
  final DateTime? unlockedAt;

  // ouvrir la capsule (ou aller vers sa page)
  final VoidCallback onTap;

  // actions optionnelles selon état
  final VoidCallback? onAddMessage; // preparing
  final VoidCallback? onDiscover; // unlocked

  const MyCapsuleCard({
    super.key,
    required this.title,
    required this.status,
    required this.onTap,
    this.opensInDays,
    this.unlockedAt,
    this.onAddMessage,
    this.onDiscover,
  });

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF8A00);

    // background selon status
    final Color bg;
    switch (status) {
      case CapsuleStatus.preparing:
      case CapsuleStatus.locked:
        bg = const Color(0xFFEDEDED);
        break;
      case CapsuleStatus.unlocked:
        bg = const Color(0xFFF1E4D9);
        break;
    }

    String formatDate(DateTime? dt) {
      if (dt == null) return "--/--/----";
      final d = dt.day.toString().padLeft(2, '0');
      final m = dt.month.toString().padLeft(2, '0');
      final y = dt.year.toString();
      return "$d/$m/$y";
    }

    final int days = opensInDays ?? 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER: titre + cadenas
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  Icon(
                    status == CapsuleStatus.unlocked
                        ? Icons.lock_open
                        : Icons.lock_outline,
                    color: status == CapsuleStatus.unlocked
                        ? orange
                        : orange,
                    size: 35,
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ZONE TOP selon status
              if (status != CapsuleStatus.unlocked) ...[
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7F9EA4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Bloqué",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // "Ouvre dans n jours"
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 24,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Ouvre dans ",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const Text(
                      "",
                    ),
                    Text(
                      "$days",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: orange,
                      ),
                    ),
                    Text(
                      " jours",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                Divider(color: Colors.black.withValues(alpha: 0.10), height: 1),
                const SizedBox(height: 10),
              ] else ...[
                // "Débloquer le : 24/01/2023"
                Row(
                  children: [
                    const Text(
                      "Débloquer le : ",
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      formatDate(unlockedAt),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                Divider(color: Colors.black.withValues(alpha: 0.10), height: 1),
                const SizedBox(height: 10),
              ],

              // ZONE BOTTOM selon status
              if (status == CapsuleStatus.preparing) ...[
                InkWell(
                  onTap: onAddMessage ?? onTap,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Ajouter un message",
                        style: TextStyle(fontSize: 16),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size:24,
                        color: orange,
                      ),
                    ],
                  ),
                ),
              ] else if (status == CapsuleStatus.locked) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Meteo requise pour déverrouiller",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6E6E6E),
                      ),
                    ),
                    const Icon(Icons.wb_sunny_outlined, color: orange),
                  ],
                ),
              ] else ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: onDiscover ?? onTap,
                    child: const Text(
                      "Découvrir",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}