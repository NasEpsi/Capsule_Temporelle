import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/my_button.dart';
import '../components/my_text_field.dart';
import '../services/auth/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  Future<void> _register() async {
    if (passwordController.text != confirmPasswordController.text) {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text("Les mots de passe ne correspondent pas"),
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();

    try {
      await auth.register(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text,
      );
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(title: Text(e.toString())),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isLoading = auth.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          child: Column(
            children: [
              const SizedBox(height: 12),

              Center(
                child: Column(
                  children: const [
                    Icon(Icons.lock_open_rounded,
                        size: 64, color: Color(0xFFFF8D28)),
                    SizedBox(height: 10),
                    Text(
                      "Créer un compte",
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 6),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              MyTextField(
                controller: nameController,
                title: "Nom",
                hintText: "ex: Votre nom",
                obscureText: false,
              ),

              const SizedBox(height: 16),

              MyTextField(
                controller: emailController,
                title: "Email",
                hintText: "ex: exemple@exemple.com",
                obscureText: false,
              ),

              const SizedBox(height: 16),

              MyTextField(
                controller: passwordController,
                title: "Mot de passe",
                hintText: "••••••••",
                obscureText: true,
              ),

              const SizedBox(height: 16),

              MyTextField(
                controller: confirmPasswordController,
                title: "Confirmation",
                hintText: "••••••••",
                obscureText: true,
              ),

              const SizedBox(height: 18),

              AbsorbPointer(
                absorbing: isLoading,
                child: MyButton(
                  text: isLoading ? "Création..." : "Créer mon compte",
                  onTap: _register,
                ),
              ),

              const SizedBox(height: 14),

              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Déjà un compte ?",
                      style: TextStyle(color: Color(0xFF6E6E6E))),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      "Se connecter",
                      style: TextStyle(
                        color: Color(0xFFFF8D28),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}