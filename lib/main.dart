import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'features/auth/views/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase commented out for UI checking
  // await Firebase.initializeApp();

  runApp(
    const ProviderScope(
      child: GigInsureApp(),
    ),
  );
}

class GigInsureApp extends StatelessWidget {
  const GigInsureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      home: const LoginScreen(),
    );
  }
}