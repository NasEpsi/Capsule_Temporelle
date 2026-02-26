import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String title;
  final String subtitle;
  final String hintText;
  final bool obscureText;

  const MyTextField({
    super.key,
    required this.controller,
    required this.title,
    required this.subtitle,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
    const Color(0xFFFF8D28).withValues(alpha: 0.65);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 4),

        // Sous-titre
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0x99000000),
          ),
        ),

        const SizedBox(height: 12),

        // Champ texte
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),

            filled: true,
            fillColor: const Color(0xFFFFFFFF),

            hintText: hintText,
            hintStyle: const TextStyle(
              color: Color(0x66000000),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide(
                color: borderColor,
                width: 1.2,
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: const BorderSide(
                color: Color(0xA6FF8D28),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}