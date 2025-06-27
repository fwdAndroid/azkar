import 'package:azkar/widgets/drawer_widget.dart';
import 'package:flutter/material.dart';

class AzkarPage extends StatefulWidget {
  const AzkarPage({super.key});

  @override
  State<AzkarPage> createState() => _AzkarPageState();
}

class _AzkarPageState extends State<AzkarPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white, // or white depending on bg
      ),
      drawer: DrawerWidget(),
      extendBodyBehindAppBar:
          true, // allows background image to go under appbar
      body: Stack(
        children: [
          Image.asset(
            "assets/bg.png",
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),
          // Add content here if needed
        ],
      ),
    );
  }
}
