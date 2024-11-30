import 'dart:async';
import 'package:flutter/material.dart';
import 'welcome_page.dart';

class SplashScreen extends StatelessWidget {
  final String initialAvatarPath;
  final String initialUserName;

  SplashScreen(
      {required this.initialAvatarPath, required this.initialUserName});

  @override
  Widget build(BuildContext context) {
    // Delay and navigate to WelcomePage
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WelcomePage(
            initialAvatarPath: initialAvatarPath,
            initialUserName: initialUserName,
          ),
        ),
      );
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/1.png', // Your logo file
              width: 200,
              height: 200,
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.blue), // Optional loader
          ],
        ),
      ),
    );
  }
}
