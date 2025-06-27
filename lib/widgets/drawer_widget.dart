import 'package:azkar/screens/drawer_pages/allah_names.dart';
import 'package:azkar/screens/drawer_pages/tasbeeh_counter.dart';
import 'package:azkar/widgets/logout_widget.dart';
import 'package:flutter/material.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color(0xff097132),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8, top: 10),
            child: Image.asset("assets/logo.png", height: 150, width: 150),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ListTile(
              title: Text(
                'Allah Names',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AllahNames()),
                );
              },
            ),
          ),
          Divider(),
          ListTile(
            title: Text(
              'Tasbeeh Counter',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w300,
                fontSize: 16,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TashbeehCounter()),
              );
            },
          ),
          Divider(),
          ListTile(
            title: Text(
              'Qibla Direction',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w300,
                fontSize: 16,
              ),
            ),
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => AllahNames()),
              // );
            },
          ),
          Divider(),
          ListTile(
            title: Text(
              'Quran',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w300,
                fontSize: 16,
              ),
            ),
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => AllahNames()),
              // );
            },
          ),
          Divider(),
          ListTile(
            title: Text(
              'Language Setting',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w300,
                fontSize: 16,
              ),
            ),
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => AllahNames()),
              // );
            },
          ),
          Divider(),
          ListTile(
            title: Text(
              'My Profile',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w300,
                fontSize: 16,
              ),
            ),
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => AllahNames()),
              // );
            },
          ),
          Divider(),
          ListTile(
            onTap: () async {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return LogoutWidget();
                },
              );
            },
            title: Text("Logout", style: TextStyle(color: Colors.white)),
            leading: Icon(Icons.logout, color: Colors.red),
          ),
        ],
      ),
    );
  }
}
