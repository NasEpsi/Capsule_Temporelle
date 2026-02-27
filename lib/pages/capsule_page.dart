import 'package:flutter/material.dart';

import '../components/my_bottom_menu.dart';
import '../components/my_chronology.dart';
import '../components/my_contributor_card.dart';
import '../components/my_floating_button.dart';
import '../components/my_message_bubble.dart';

class CapsuleDetailsPage extends StatelessWidget {
  const CapsuleDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF8F5F0);

    // --- Données d'exemple
    const capsuleTitle = "Anniversaire de Julie";
    const isLocked = true;

    final createdAt = DateTime(2023, 2, 25);
    final unlockAt = DateTime(2026, 6, 15);

    final contributors = <String>["Papa", "Maman", "Tata"]; // remplacer par liste dynamique

    final messages = [
      {
        "name": "Papa",
        "date": DateTime.now().subtract(const Duration(days: 365 * 3)),
        "text": "Tu te rappelles des vacances à Londres",
      },
      {
        "name": "Maman",
        "date": DateTime.now().subtract(const Duration(days: 365 * 2)),
        "text":
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud",
      },
    ];

    return Scaffold(
      backgroundColor: bg,

      bottomNavigationBar: MyBottomMenu(
        currentIndex: 1,
      ),

      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        "Détails de la capsule",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  Divider(color: Colors.black.withValues(alpha: 0.1)),
                  const SizedBox(height: 10),

                  // Titre capsule + status
                  Text(
                    capsuleTitle,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Chip status
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      isLocked ? "Bloqué" : "Débloqué",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Gros cadenas central (comme maquette)
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3C3C43).withValues(alpha: 0.60),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_outline,
                        size: 110,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Chronologie (composant)
                  MyChronologyCard(
                    createdAt: createdAt,
                    unlockAt: unlockAt,
                    condition: WeatherCondition.sun,
                  ),

                  const SizedBox(height: 14),

                  // Contributeurs (composant)
                  MyContributorsCard(
                    title: 'Contributeurs',
                    contributors: contributors,
                  ),

                  const SizedBox(height: 15),
                  Divider(color: const Color(0xFFD9D9D9)),
                  const SizedBox(height: 15),

                  // Messages
                  ...messages.map((m) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: MyMessageBubble(
                        senderName: m["name"] as String,
                        createdAt: m["date"] as DateTime,
                        message: m["text"] as String,
                      ),
                    );
                  }),

                  const SizedBox(height: 90),
                ],
              ),
            ),

            Positioned.fill(
              child: IgnorePointer(
                ignoring: false,
                child: DraggableCreateCapsuleButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}