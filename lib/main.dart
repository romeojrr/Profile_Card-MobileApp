import 'package:flutter/material.dart';
import 'theme/glass_theme.dart';
import 'models/auth_service.dart';
import 'screens/auth_screen.dart';
import 'screens/main_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProfileCardApp());
}

class ProfileCardApp extends StatelessWidget {
  const ProfileCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    final loggedIn = AuthService().currentUser != null;
    return MaterialApp(
      title: 'CapyHub',
      debugShowCheckedModeBanner: false,
      theme: GlassTheme.buildTheme(),
      home: loggedIn ? const MainShell() : const AuthScreen(),
    );
  }
}
