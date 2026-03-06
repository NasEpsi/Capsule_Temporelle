import 'package:flutter/material.dart';

import '../components/my_button.dart';
import '../components/my_text_field.dart';


class AddMemberPage extends StatefulWidget {
  const AddMemberPage({super.key});

  @override
  State<AddMemberPage> createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage> {
  final _memberController = TextEditingController();

  @override
  void dispose() {
    _memberController.dispose();
    super.dispose();
  }

  void _addMember() {
    final member = _memberController.text.trim();
    if (member.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Entrez un nom ou un email")),
      );
      return;
    }

    // TODO: branche ta logique (API / DatabaseProvider)


    Navigator.pop(context, member);
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF8F5F0);

    return Scaffold(
      backgroundColor: bg,
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
                  const SizedBox(width: 5),
                  const Text(
                    "Ajouter un membre",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Divider(color: Colors.black.withValues(alpha: 0.10)),
              const SizedBox(height: 20),

              MyTextField(
                controller: _memberController,
                title: "Nom / Email",
                subtitle: "Ajoute un membre à ton groupe de famille",
                hintText: "ex: julie@mail.com",
                obscureText: false,
              ),

              const SizedBox(height: 20),

              MyButton(
                text: "Ajouter",
                onTap: _addMember,
              ),
            ],
          ),
        ),
      ),
    );
  }
}