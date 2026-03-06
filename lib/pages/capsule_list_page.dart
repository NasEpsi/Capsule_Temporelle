import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database/database_provider.dart';
import '../models/capsule.dart';
import '../components/my_capsule_card.dart';
import '../components/my_floating_button.dart';
import 'create_capsule_page.dart';

class CapsuleListPage extends StatefulWidget {
  const CapsuleListPage({super.key});

  @override
  State<CapsuleListPage> createState() => _CapsulesListPageState();
}

class _CapsulesListPageState extends State<CapsuleListPage> {
  bool _bootDone = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _bootDone) return;
      _bootDone = true;

      final db = context.read<DatabaseProvider>();

      await Future.wait([
        db.fetchMyCapsules(),
        db.fetchWeatherAuxerre(),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF6F1EC); // proche de ta capture

    return Consumer<DatabaseProvider>(
      builder: (_, db, __) {
        final userName = db.currentUser?.name ?? "Utilisateur";

        final forLovedOnes =
        db.capsules.where((c) => c.memberRole == "BENEFICIARY").toList();
        final mine =
        db.capsules.where((c) => c.memberRole != "BENEFICIARY").toList();

        return Scaffold(
          backgroundColor: bg,
          body: SafeArea(
            child: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () async {
                    await db.fetchMyCapsules();
                    await db.fetchWeatherAuxerre();
                  },
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 120),
                    children: [
                      _Header(userName: userName),
                      const SizedBox(height: 10),

                      const Text(
                        "Capsules pour vos proches",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (db.error != null && db.capsules.isEmpty)
                        _ErrorBox(message: db.error!)
                      else ...[
                          if (forLovedOnes.isEmpty)
                            const _EmptyHint(text: "Aucune capsule")
                          else
                            ...forLovedOnes.map(
                                  (c) => Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: _CapsuleTile(capsule: c),
                              ),
                            ),

                          const SizedBox(height: 16),

                          const Text(
                            "Vos capsules",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),

                          if (mine.isEmpty)
                            const _EmptyHint(
                              text: "Aucune capsule",
                            )
                          else
                            ...mine.map(
                                  (c) => Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: _CapsuleTile(capsule: c),
                              ),
                            ),
                        ],
                    ],
                  ),
                ),

                DraggableCreateCapsuleButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateCapsulePage()),
                    );

                    // refresh après retour
                    await context.read<DatabaseProvider>().fetchMyCapsules();
                  },
                ),
              ],
            ),
          ),

          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 0,
            selectedItemColor: const Color(0xFFFF8A00),
            unselectedItemColor: Colors.black54,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: "Accueil",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.mail_outline),
                label: "Capsule",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: "Profil",
              ),
            ],
            onTap: (i) {},
          ),
        );
      },
    );
  }
}

class _CapsuleTile extends StatelessWidget {
  final Capsule capsule;
  const _CapsuleTile({required this.capsule});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isTimeLocked = now.isBefore(capsule.unlockAt);

    final CapsuleStatus status;
    if (!isTimeLocked) {
      status = CapsuleStatus.unlocked;
    } else if (capsule.canWrite) {
      status = CapsuleStatus.preparing;
    } else {
      status = CapsuleStatus.locked;
    }

    final daysLeft = capsule.unlockAt.difference(now).inDays;
    final safeDays = daysLeft < 0 ? 0 : daysLeft;

    return MyCapsuleCard(
      title: capsule.title,
      status: status,
      opensInDays: safeDays,
      unlockedAt: capsule.unlockAt,
      onTap: () {
        // TODO: push vers la page capsule detail
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Ouvrir capsule: ${capsule.title}")),
        );
      },
      onAddMessage: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Ajouter un message: ${capsule.title}")),
        );
      },
      onDiscover: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Découvrir: ${capsule.title}")),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final String userName;
  const _Header({required this.userName});

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF8A00);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Bonjour",
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            context.read<AuthProvider>().logout();
          },
        ),
        const SizedBox(height: 2),
        Text(
          userName,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: orange,
          ),
        ),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.black54),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.withOpacity(0.25)),
      ),
      child: Text(
        message,
        style: TextStyle(color: Colors.red.shade700),
      ),
    );
  }
}