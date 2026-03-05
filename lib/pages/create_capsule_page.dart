import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/my_weather_square.dart';
import '../components/my_bottom_menu.dart';
import '../components/my_button.dart';
import '../components/my_date_field.dart';
import '../components/my_text_field.dart';
import '../services/database/database_provider.dart';

class CreateCapsulePage extends StatefulWidget {
  const CreateCapsulePage({super.key});

  @override
  State<CreateCapsulePage> createState() => _CreateCapsulePageState();
}

class _CreateCapsulePageState extends State<CreateCapsulePage> {
  final _capsuleNameController = TextEditingController();
  final _beneficiaryEmailController = TextEditingController();
  final _dateController = TextEditingController();

  final List<TextEditingController> _contributorControllers = [];

  WeatherType _selectedWeather = WeatherType.sun;
  bool _submitting = false;

  @override
  void dispose() {
    _capsuleNameController.dispose();
    _beneficiaryEmailController.dispose();
    _dateController.dispose();
    for (final c in _contributorControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addContributorField() {
    setState(() {
      _contributorControllers.add(TextEditingController());
    });
  }

  void _removeContributorField(int index) {
    setState(() {
      _contributorControllers[index].dispose();
      _contributorControllers.removeAt(index);
    });
  }

  String _mapWeatherToApi(WeatherType w) {
    switch (w) {
      case WeatherType.sun:
        return "SUNNY";
      case WeatherType.cloudy:
        return "CLOUDY";
      case WeatherType.rain:
        return "RAINY";
      case WeatherType.snow:
        return "SNOWY";
    }
  }

  bool _isValidEmail(String s) {
    final email = s.trim();
    if (email.isEmpty) return true; // ✅ optionnel
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  }

  DateTime? _parseDate(String input) {
    final s = input.trim();
    if (s.isEmpty) return null;

    final iso = DateTime.tryParse(s);
    if (iso != null) return iso;

    final m = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(s);
    if (m != null) {
      final d = int.parse(m.group(1)!);
      final mo = int.parse(m.group(2)!);
      final y = int.parse(m.group(3)!);
      return DateTime(y, mo, d, 12, 0);
    }
    return null;
  }

  Future<void> _submit() async {
    if (_submitting) return;

    final capsuleName = _capsuleNameController.text.trim();
    final dateText = _dateController.text.trim();

    final beneficiaryEmail = _beneficiaryEmailController.text.trim();
    final contributorEmails = _contributorControllers
        .map((c) => c.text.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (capsuleName.isEmpty || dateText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nom de capsule et date obligatoires.")),
      );
      return;
    }

    if (!_isValidEmail(beneficiaryEmail)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email bénéficiaire invalide.")),
      );
      return;
    }

    for (final e in contributorEmails) {
      if (!_isValidEmail(e)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Email contributeur invalide: $e")),
        );
        return;
      }
    }

    final unlockAt = _parseDate(dateText);
    if (unlockAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Date invalide (ex: 24/01/2027).")),
      );
      return;
    }

    if (!unlockAt.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La date d'ouverture doit être dans le futur.")),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final db = context.read<DatabaseProvider>();

      // 1) create capsule
      final created = await db.createCapsule(
        title: capsuleName,
        description: null,
        unlockAt: unlockAt,
        requiredSky: _mapWeatherToApi(_selectedWeather),
      );

      if (created == null) {
        throw Exception(db.error ?? "Création échouée");
      }

      // 2) add invites (optionnel)
      if (beneficiaryEmail.isNotEmpty || contributorEmails.isNotEmpty) {
        await db.addMember(
          capsuleId: created.id,
          beneficiaryEmail: beneficiaryEmail.isEmpty ? null : beneficiaryEmail,
          contributorEmails: contributorEmails,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Capsule créée ✅")),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e")),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF8F5F0);

    return Scaffold(
      backgroundColor: bg,
      bottomNavigationBar: MyBottomMenu(currentIndex: 1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    "Création de la capsule",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              Divider(color: Colors.black.withOpacity(0.10)),
              const SizedBox(height: 14),

              MyTextField(
                controller: _capsuleNameController,
                title: "Nom de la capsule",
                hintText: "ex: Anniversaire Julie",
                obscureText: false,
              ),
              const SizedBox(height: 18),

              // Beneficiary email optionnel
              MyTextField(
                controller: _beneficiaryEmailController,
                title: "Email du bénéficiaire (optionnel)",
                hintText: "ex: test@email.com",
                obscureText: false,
              ),
              const SizedBox(height: 18),

              // Contributeurs
              const Text(
                "Contributeurs (optionnel)",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),

              if (_contributorControllers.isEmpty)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black.withOpacity(0.06)),
                  ),
                  child: const Text(
                    "Aucun contributeur pour l’instant.",
                    style: TextStyle(color: Colors.black54),
                  ),
                )
              else
                ..._contributorControllers.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final ctrl = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: MyTextField(
                            controller: ctrl,
                            title: "Email contributeur",
                            hintText: "ex: ami@email.com",
                            obscureText: false,
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          onPressed: () => _removeContributorField(idx),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  );
                }),

              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _addContributorField,
                icon: const Icon(Icons.add),
                label: const Text("Ajouter un contributeur"),
              ),

              const SizedBox(height: 18),

              MyDateField(
                controller: _dateController,
                title: "Date de l’ouverture de la capsule",
                subtitle: "Choissiser une date spécial",
              ),

              const SizedBox(height: 18),

              const Text(
                "Météo",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              const Text(
                "Choissiser la météo parfaite",
                style: TextStyle(fontSize: 16, color: Color(0xFF7A7A7A)),
              ),
              const SizedBox(height: 14),

              Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  WeatherSquare(
                    type: WeatherType.sun,
                    isActive: _selectedWeather == WeatherType.sun,
                    onTap: () => setState(() => _selectedWeather = WeatherType.sun),
                  ),
                  WeatherSquare(
                    type: WeatherType.rain,
                    isActive: _selectedWeather == WeatherType.rain,
                    onTap: () => setState(() => _selectedWeather = WeatherType.rain),
                  ),
                  WeatherSquare(
                    type: WeatherType.cloudy,
                    isActive: _selectedWeather == WeatherType.cloudy,
                    onTap: () => setState(() => _selectedWeather = WeatherType.cloudy),
                  ),
                  WeatherSquare(
                    type: WeatherType.snow,
                    isActive: _selectedWeather == WeatherType.snow,
                    onTap: () => setState(() => _selectedWeather = WeatherType.snow),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              MyButton(
                text: _submitting ? "Création..." : "Créer la capsule",
                onTap: _submitting ? () {} : _submit,
              ),

              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}