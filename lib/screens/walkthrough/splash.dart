import 'dart:async';
import 'package:bnn/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './walkthroughPage.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    Timer(Duration(seconds: 2), () async {
      await authProvider.init();
      if (authProvider.isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
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
