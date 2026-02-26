import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/my_button.dart';
import '../components/my_text_field.dart';
import '../services/auth/auth_provider.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> _login() async {
    final auth = context.read<AuthProvider>();

    try {
      await auth.login(emailController.text.trim(), passwordController.text);
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
    emailController.dispose();
    passwordController.dispose();
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              Center(
                child: Column(
                  children: const [
                    Icon(Icons.hourglass_bottom_rounded,
                        size: 64, color: Color(0xFFFF8D28)),
                    SizedBox(height: 10),
                    Text(
                      "CapsuleTemporelle",
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Connecte-toi pour accéder à tes capsules",
                      style: TextStyle(fontSize: 15, color: Color(0xFF6E6E6E)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              MyTextField(
                controller: emailController,
                title: "Email",
                hintText: "ex: test@mail.com",
                obscureText: false,
              ),

              const SizedBox(height: 16),

              MyTextField(
                controller: passwordController,
                title: "Mot de passe",
                hintText: "••••••••",
                obscureText: true,
              ),

              const SizedBox(height: 18),

              AbsorbPointer(
                absorbing: isLoading,
                child: MyButton(
                  text: isLoading ? "Connexion..." : "Connexion",
                  onTap: _login,
                ),
              ),

              const SizedBox(height: 14),

              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Pas encore de compte ?",
                      style: TextStyle(color: Color(0xFF6E6E6E))),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      "Créer un compte",
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