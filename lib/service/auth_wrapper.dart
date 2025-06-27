// lib/screens/auth/auth_wrapper.dart
import 'package:azkar/screens/auth/login_screen.dart';
import 'package:azkar/screens/main/main_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // User is logged in
        if (snapshot.hasData && snapshot.data != null) {
          return const MainDashboard();
        }
        // User is not logged in
        return const LoginScreen();
      },
    );
  }
}
