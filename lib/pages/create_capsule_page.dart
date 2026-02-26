import 'package:flutter/material.dart';

import '../components/my_weather_square.dart';
import '../components/my_bottom_menu.dart';
import '../components/my_button.dart';
import '../components/my_date_field.dart';
import '../components/my_text_field.dart';


class CreateCapsulePage extends StatefulWidget {
  const CreateCapsulePage({super.key});

  @override
  State<CreateCapsulePage> createState() => _CreateCapsulePageState();
}

class _CreateCapsulePageState extends State<CreateCapsulePage> {
  final _capsuleNameController = TextEditingController();
  final _beneficiaryController = TextEditingController();
  final _dateController = TextEditingController();

  WeatherType _selectedWeather = WeatherType.sun;

  @override
  void dispose() {
    _capsuleNameController.dispose();
    _beneficiaryController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _submit() {
    final capsuleName = _capsuleNameController.text.trim();
    final beneficiary = _beneficiaryController.text.trim();
    final dateText = _dateController.text.trim();
    final weather = _selectedWeather;

    // validation + API
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF8F5F0);

    return Scaffold(
      backgroundColor: bg,

      bottomNavigationBar: MyBottomMenu(
        currentIndex: 1,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
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
                  const SizedBox(width: 6),
                  const Text(
                    "Création de la capsule",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Divider(color: Colors.black.withValues(alpha: 0.10)),
              const SizedBox(height: 14),

              // Nom de la capsule
              MyTextField(
                controller: _capsuleNameController,
                title: "Nom de la capsule",
                subtitle: "Donner un nom à ce moment",
                hintText: "ex: Anniversaire User2",
                obscureText: false,
              ),

              const SizedBox(height: 18),

              // Nom du bénéficiaire
              MyTextField(
                controller: _beneficiaryController,
                title: "Nom du beneficiaire",
                subtitle: "Choissiser à qui va être destiné cette capsule",
                hintText: "ex: User2",
                obscureText: false,
              ),

              const SizedBox(height: 18),

              // Date ouverture
              MyDateField(
                controller: _dateController,
                title: "Date de l’ouverture de la capsule",
                subtitle: "Choissiser une date spécial",
              ),

              const SizedBox(height: 18),

              // Météo
              const Text(
                "Météo",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Choissiser la météo parfaite",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7A7A7A),
                ),
              ),
              const SizedBox(height: 14),

              // 2x2 carrés météo
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

              // Bouton créer capsule
              MyButton(
                text: "Créer la capsule",
                onTap: _submit,
              ),

              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}