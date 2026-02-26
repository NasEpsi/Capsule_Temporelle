import 'package:flutter/material.dart';

// importation des pages
import 'package:capsule_emporelle_flutter/components/capsule_temporelle/lib/pages/home_page.dart';
import 'package:capsule_emporelle_flutter/components/capsule_temporelle/lib/pages/capsule_list_page.dart';
import 'package:capsule_emporelle_flutter/components/capsule_temporelle/lib/pages/profile_page.dart';
import '../services/auth/auth_service.dart';

/*
 *
 * BOTTOM MENU
 *
 * -----------------------------------------------------
 * - Accueil
 * - Capsule
 * - Profile
 *
 * It needs:
 * - currentIndex (int) → index of selected item (for active color)
 */

class MyBottomMenu extends StatelessWidget {
  final int currentIndex;

  MyBottomMenu({
    super.key,
    required this.currentIndex,
  });

  // auth service
  final _auth = AuthService();

  void _goTo(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.black54,

        onTap: (index) {
          // si on clique sur l'onglet déjà actif → ne rien faire
          if (index == currentIndex) return;

          switch (index) {
            case 0:
              _goTo(context, const HomePage());
              break;

            case 1:
              _goTo(context, const ConversationListPage());
              break;

            case 2:
              _goTo(
                context,
                ProfilePage(uid: _auth.getCurrentUid()),
              );
              break;
          }
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Accueil",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox_outlined),
            activeIcon: Icon(Icons.inbox),
            label: "Capsule",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}