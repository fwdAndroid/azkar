import 'package:azkar/provider/language_provider.dart';
import 'package:azkar/screens/main/main_dashboard.dart';
import 'package:azkar/utils/show_message.dart';
import 'package:azkar/widgets/save_button_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController nameController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    setState(() {
      nameController.text = data['username'] ?? '';
      locationController.text = data['address'] ?? "";
      phoneController.text = data['phone'] ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context); // Access

    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
          title: Text(
            languageProvider.localizedStrings["Edit Profile"] ?? "Edit Profile",
            style: TextStyle(color: Colors.white),
          ),
        ),

        body: Stack(
          children: [
            Image.asset(
              "assets/bg.png",
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.cover,
            ),
            SingleChildScrollView(
              padding: EdgeInsets.only(top: kToolbarHeight + 32),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset("assets/logo.png", height: 200),
                  ),

                  // Full Name Input
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: "Your Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: TextField(
                      controller: locationController,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: "Location",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.numberWithOptions(),
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: "Phone Number",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Profile Image Section

            // Save Button
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF1D3B2A),
                        ),
                      )
                    : SaveButton(
                        title:
                            languageProvider.localizedStrings["Edit Profile"] ??
                            "Edit Profile",
                        onTap: () async {
                          setState(() {
                            _isLoading = true;
                          });

                          try {
                            await FirebaseFirestore.instance
                                .collection("users")
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .update({
                                  "username": nameController.text,
                                  "address": locationController.text,
                                  "phone": phoneController.text,
                                });
                            showMessageBar(
                              languageProvider
                                      .localizedStrings["Successfully Updated Profile"] ??
                                  "Successfully Updated Profile",
                              context,
                            );
                          } catch (e) {
                            showMessageBar(
                              languageProvider
                                      .localizedStrings["Profile could not be updated"] ??
                                  "Profile could not be updated",
                              context,
                            );
                          } finally {
                            setState(() {
                              _isLoading = false;
                            });
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (builder) => MainDashboard(),
                              ),
                            );
                          }
                        },
                      ),
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
