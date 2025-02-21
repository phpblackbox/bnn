import 'package:flutter/material.dart';

class SplashLogo extends StatelessWidget {
  final double height; // Optional: Allow customization of the logo height

  const SplashLogo({Key? key, this.height = 200})
      : super(key: key); // Default height

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 16),
      child: SizedBox(
        height: height,
        child: Center(
          child: Image.asset(
            'assets/images/splash_bnn_logo.png',
            height: height,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
