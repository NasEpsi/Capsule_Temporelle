import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/auth/auth_gate.dart';
import 'services/auth/auth_provider.dart';
import 'services/database/database_provider.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, DatabaseProvider>(
          create: (_) => DatabaseProvider(),
          update: (_, auth, db) {
            db ??= DatabaseProvider();
            db.setToken(auth.token);
            db.currentUser = auth.user;
            return db;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppColors,
      home: const AuthGate(),
    );
  }
}