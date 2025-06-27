import 'package:azkar/screens/auth/login_screen.dart';
import 'package:azkar/utils/show_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LogoutWidget extends StatelessWidget {
  const LogoutWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final GoogleSignIn _googleSignIn = GoogleSignIn();

    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            child: ListBody(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset("assets/Image.png", height: 120),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Oh No, you're leaving",
                      style: GoogleFonts.workSans(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Are you sure you want to log out?",
                      style: GoogleFonts.workSans(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: <Widget>[
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("No", style: TextStyle(color: Colors.black)),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () async {
                // Sign out from Firebase
                await FirebaseAuth.instance.signOut();
                await _googleSignIn.signOut();

                // Sign out from Google

                // Navigate to login screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (builder) => LoginScreen()),
                );

                // Show snack bar message
                showMessageBar("Logout Successfully", context);
              },
              child: Text("Yes", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                fixedSize: Size(137, 50),
                backgroundColor: Color(0xFF097132),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
