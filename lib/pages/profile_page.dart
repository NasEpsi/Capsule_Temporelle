import 'package:capsule_emporelle_flutter/pages/add_member_page.dart';
import 'package:capsule_emporelle_flutter/pages/parameter_page.dart';
import 'package:flutter/material.dart';

import '../components/my_bottom_menu.dart';
import '../components/my_button.dart';
import '../components/my_button_card.dart';
import '../components/my_contributor_card.dart';
import '../components/my_floating_button.dart';


class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF8F5F0);

    // Données exemple
    const userName = "Utilisateur";
    const userEmail = "test@test.test";
    final familyMembers = ["User1", "User2"];

    return Scaffold(
      backgroundColor: bg,

      bottomNavigationBar: MyBottomMenu(
        currentIndex: 2,
      ),

      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Header du profil
                  Row(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: const Color(0x33FF8D28),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          size: 90,
                          color: Color(0xFFFF9230),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            userName,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            userEmail,
                            style: TextStyle(
                              fontSize: 20,
                              color: Color(0x99000000),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  MyContributorsCard(
                    title: "Groupe de famille",
                    contributors: familyMembers,
                  ),

                  const SizedBox(height: 25),

                  MyNavCardButton(
                    icon: Icons.group_outlined,
                    title: "Membres de la famille",
                    page: const AddMemberPage(),
                  ),

                  const SizedBox(height: 15),

                  MyNavCardButton(
                    icon: Icons.settings_outlined,
                    title: "Paramètres",
                    page: const ParametersPage(),
                  ),

                  const SizedBox(height: 25),

                  MyButton(
                    text: "Se déconnecter",
                    onTap: () {
                      // TODO: AuthService().logout()
                    },
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),

            const DraggableCreateCapsuleButton(),
          ],
        ),
      ),
    );
  }
}