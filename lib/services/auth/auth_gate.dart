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
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = Future.microtask(() => context.read<AuthProvider>().init());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (_, snap) {
        final auth = context.watch<AuthProvider>();

        if (snap.connectionState == ConnectionState.waiting ||
            auth.status == AuthStatus.loading) {
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