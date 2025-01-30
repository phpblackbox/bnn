import 'dart:async';
import 'package:bnn/main.dart';
import 'package:flutter/material.dart';
import './walkthroughPage.dart';
import 'package:bnn/utils/constants.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    // Start a timer to navigate to the next page after 3 seconds
    Timer(Duration(seconds: 1), () async {
      if (supabase.auth.currentUser == null) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });

    return Scaffold(
      backgroundColor: Colors.white, // Customize according to your theme
      body: Center(
        child: Image.asset('assets/images/splash_bnn_logo.png'),
      ),
    );
  }
}
