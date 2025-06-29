import 'package:azkar/provider/language_provider.dart';
import 'package:azkar/screens/auth/login_screen.dart';
import 'package:azkar/screens/main/main_dashboard.dart';
import 'package:azkar/service/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_login_buttons/social_login_buttons.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool isLoading = false; // Loading state
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();
  final AuthService _authService =
      AuthService(); // Create auth service instance
  void _handleAuth() async {
    setState(() => isLoading = true);

    try {
      User? user;

      user = await _authService.registerWithEmailPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
        usernameController.text.trim(),
      );

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainDashboard()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _handleGoogleSignIn() async {
    setState(() => isLoading = true);
    try {
      User? user = await _authService.signInWithGoogle();
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainDashboard()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Google sign-in failed: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context); // Access

    return Scaffold(
      resizeToAvoidBottomInset: true, // Important for keyboard interaction
      body: SafeArea(
        child: Stack(
          children: [
            Image.asset(
              "assets/bg.png",
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
            SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Image.asset("assets/logo.png", height: 150),
                  const SizedBox(height: 20),
                  Text(
                    languageProvider.localizedStrings["SignUp to Azkar App"] ??
                        'SignUp to Azkar App',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    languageProvider
                            .localizedStrings["Begin each day with guidance from Allah.\n Let prayer shape your path and purpose."] ??
                        'Begin each day with guidance from Allah.\n Let prayer shape your path and purpose.',
                    textAlign: TextAlign.center,

                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),

                  /// Email Field
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 8, top: 8),
                      child: Text(
                        languageProvider.localizedStrings["User Name"] ??
                            "User Name",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 8.0,
                      right: 8,
                      bottom: 8,
                    ),
                    child: TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText:
                            languageProvider.localizedStrings["Your Name"] ??
                            "Your Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  /// Email Field
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 8, top: 8),
                      child: Text(
                        languageProvider.localizedStrings["Email address"] ??
                            "Email address",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 8.0,
                      right: 8,
                      bottom: 8,
                    ),
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText:
                            languageProvider.localizedStrings["Your email"] ??
                            "Your email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 8, top: 8),
                      child: Text(
                        languageProvider.localizedStrings["Password"] ??
                            "Password",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 8.0,
                      right: 8,
                      bottom: 8,
                    ),
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText:
                            languageProvider.localizedStrings["Password"] ??
                            "Password",
                        suffixIcon: Icon(Icons.visibility_off),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF097132),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: isLoading ? null : _handleAuth,
                          child: Text(
                            languageProvider.localizedStrings["Sign Up"] ??
                                "Sign Up",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    languageProvider
                            .localizedStrings["Other sign in options"] ??
                        "Other sign in options",
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  SocialLoginButton(
                    height: 55,
                    width: 300,
                    borderRadius: 10,
                    mode: SocialLoginButtonMode.multi,
                    buttonType: SocialLoginButtonType.google,
                    onPressed: isLoading ? null : _handleGoogleSignIn,
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (builder) => LoginScreen()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        languageProvider
                                .localizedStrings["Already have an account? Sign In"] ??
                            "Already have an account? Sign In",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
