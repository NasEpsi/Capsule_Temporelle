import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/database/database_provider.dart';
import '../models/capsule.dart';

class CapsuleListPage extends StatefulWidget {
  const CapsuleListPage({super.key});

  @override
  State<CapsuleListPage> createState() => _CapsulesListPageState();
}

class _CapsulesListPageState extends State<CapsuleListPage> {
  bool _loadedOnce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadedOnce) return;
    _loadedOnce = true;

    // Charge capsules du user connecté + météo (Auxerre par défaut)
    Future.microtask(() async {
      final db = context.read<DatabaseProvider>();
      await db.fetchMyCapsules();
      await db.fetchWeatherAuxerre();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Consumer<DatabaseProvider>(
      builder: (_, db, __) {
        final userName = db.currentUser?.name ?? "Utilisateur";

        // Séparation : proches = beneficiary, vos capsules = owner+contributor
        final forLovedOnes = db.capsules.where((c) => c.memberRole == "BENEFICIARY").toList();
        final mine = db.capsules.where((c) => c.memberRole != "BENEFICIARY").toList();

        return Scaffold(
          backgroundColor: scheme.surface,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                await db.fetchMyCapsules();
                await db.fetchWeatherAuxerre();
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                children: [
                  _Header(userName: userName),
                  const SizedBox(height: 18),

                  if (db.loading && db.capsules.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (db.error != null && db.capsules.isEmpty)
                    _ErrorBox(message: db.error!)
                  else ...[
                      _SectionTitle(
                        title: "Capsules pour vos proches",
                        subtitle: "Capsules pour vos proches",
                      ),
                      const SizedBox(height: 10),
                      if (forLovedOnes.isEmpty)
                        _EmptyHint(text: "Aucune capsule en tant que bénéficiaire pour le moment.")
                      else
                        ...forLovedOnes.map((c) => _CapsuleCard(capsule: c)).toList(),

                      const SizedBox(height: 20),

                      _SectionTitle(title: "Vos capsules"),
                      const SizedBox(height: 10),
                      if (mine.isEmpty)
                        _EmptyHint(text: "Aucune capsule créée / contribué pour le moment.")
                      else
                        ...mine.map((c) => _CapsuleCard(capsule: c)).toList(),
                    ],
                ],
              ),
            ),
          ),

          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Plus tard : navigate -> CreateCapsulePage()
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Création de capsule : bientôt")),
              );
            },
            backgroundColor: scheme.primary,
            foregroundColor: scheme.inversePrimary,
            child: const Icon(Icons.add, size: 28),
          ),

          // Optionnel : tu pourras remplacer par ton vrai système de navigation
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 1,
            selectedItemColor: scheme.primary,
            unselectedItemColor: Colors.black54,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Accueil"),
              BottomNavigationBarItem(icon: Icon(Icons.mail_outline), label: "Capsule"),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profil"),
            ],
            onTap: (i) {
              // Tu gèreras la navigation plus tard (pages principales)
              // i == 1 => déjà ici
            },
          ),
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
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Bonjour",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          userName,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  const _SectionTitle({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (subtitle != null)
          Text(
            subtitle!,
            style: t.bodyLarge?.copyWith(color: Colors.black87),
          ),
        if (subtitle != null) const SizedBox(height: 2),
        if (subtitle == null)
          Text(
            title,
            style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }
}

class _CapsuleCard extends StatelessWidget {
  final Capsule capsule;
  const _CapsuleCard({required this.capsule});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final now = DateTime.now();
    final daysLeft = capsule.unlockAt.difference(now).inDays;

    final timeLocked = now.isBefore(capsule.unlockAt);
    final isLocked = timeLocked; // météo-lock plus tard si tu veux (après messages + page capsule)

    final statusText = isLocked ? "Bloqué" : "Disponible";
    final statusBg = isLocked ? Colors.blueGrey.shade300 : scheme.tertiary;
    final statusFg = isLocked ? Colors.white : Colors.white;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 10),
            )
          ],
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + lock icon
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    capsule.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  isLocked ? Icons.lock_outline : Icons.lock_open_outlined,
                  color: scheme.primary,
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Status pill
            Row(
              children: [
                _Pill(
                  text: statusText,
                  bg: statusBg,
                  fg: statusFg,
                ),
                const SizedBox(width: 10),
                Text(
                  capsule.memberRole == null ? "" : capsule.roleLabelFr,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: Colors.black.withOpacity(0.08), height: 1),
            const SizedBox(height: 10),

            // Date line
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.black54),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isLocked
                        ? "Ouvre dans ${daysLeft < 0 ? 0 : daysLeft} jours"
                        : "Débloquée",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black87),
                  ),
                ),
                if (!isLocked) _DiscoverButton(),
              ],
            ),

            // Meteo required (affiché surtout quand bloqué)
            if (isLocked) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Météo requise pour déverrouiller",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  Icon(_requiredIcon(capsule.requiredSky), color: scheme.primary, size: 20),
                ],
              ),
            ],

            // CTA
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  capsule.canWrite ? "Ajouter un message" : "Lecture seule",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: capsule.canWrite ? Colors.black87 : Colors.black45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward, color: scheme.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _requiredIcon(String requiredSky) {
    switch (requiredSky) {
      case "SUNNY":
        return Icons.wb_sunny_outlined;
      case "CLOUDY":
        return Icons.cloud_outlined;
      case "RAINY":
        return Icons.umbrella_outlined;
      case "SNOWY":
        return Icons.ac_unit;
      default:
        return Icons.wb_sunny_outlined;
    }
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;

  const _Pill({required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DiscoverButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        "Découvrir",
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: scheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
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
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
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
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red.shade700),
      ),
    );
  }
}