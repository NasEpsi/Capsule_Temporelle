import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyDateField extends StatefulWidget {
  final TextEditingController controller;
  final String title;
  final String subtitle;

  const MyDateField({
    super.key,
    required this.controller,
    required this.title,
    required this.subtitle,
  });

  @override
  State<MyDateField> createState() => _MyDateFieldState();
}

class _MyDateFieldState extends State<MyDateField> {

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // empêche de mettre des dates passées
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      final formattedDate = DateFormat('dd/MM/yyyy').format(picked);
      widget.controller.text = formattedDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor =
    const Color(0xA6FF8D28);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 5),

        // Sous-titre
        Text(
          widget.subtitle,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0x99000000),
          ),
        ),

        const SizedBox(height: 10),

        // Champ date
        GestureDetector(
          onTap: () => _selectDate(context),
          child: AbsorbPointer(
            child: TextField(
              controller: widget.controller,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                filled: true,
                fillColor: const Color(0xFFFFFFFF),

                hintText: "JJ/MM/AAAA",
                hintStyle: const TextStyle(
                  color: Color(0xFF000000),
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
                    color: const Color(0xA6FF8D28),
                    width: 1.5,
                  ),
                ),

                suffixIcon: const Icon(Icons.calendar_today),
              ),
            ),
          ),
        ),
      ],
    );
  }
}