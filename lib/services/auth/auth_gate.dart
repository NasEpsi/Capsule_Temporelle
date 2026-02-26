import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../pages/home_page.dart';
import 'auth_provider.dart';
import 'login_or_register.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _initDone = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initDone) {
      _initDone = true;
      context.read<AuthProvider>().init();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) {
        if (auth.status == AuthStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (auth.status == AuthStatus.authenticated) {
          return const HomePage();
        }

        return const LoginOrRegister();
      },
    );
  }
}