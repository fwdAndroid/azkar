import 'package:azkar/screens/setting/edit_profile.dart';
import 'package:azkar/widgets/logout_widget.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            "assets/bg.png",
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset("assets/logo.png", height: 150),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (builder) => EditProfile()),
                    // );
                  },
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
                  title: Text(
                    "Notifications",
                    style: TextStyle(color: Colors.white),
                  ),
                  leading: Icon(Icons.notifications, color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (builder) => EditProfile()),
                    );
                  },
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
                  title: Text(
                    "Edit Profile",
                    style: TextStyle(color: Colors.white),
                  ),
                  leading: Icon(Icons.person, color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
                child: ListTile(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (builder) => ChangeLangage()),
                    // );
                  },
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
                  title: Text(
                    "Change Language",
                    style: TextStyle(color: Colors.white),
                  ),
                  leading: Icon(Icons.language, color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
                child: ListTile(
                  onTap: () {
                    shareApp();
                  },
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
                  title: Text(
                    "Invite Friends",
                    style: TextStyle(color: Colors.white),
                  ),
                  leading: Icon(Icons.share, color: Colors.white),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.bottomCenter,
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
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return LogoutWidget();
                        },
                      );
                    },
                    child: Text(
                      "Log out",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void shareApp() {
    String appLink =
        "https://play.google.com/store/apps/details?id=com.example.yourapp";
    Share.share("Hey, check out this amazing app: $appLink");
  }
}
