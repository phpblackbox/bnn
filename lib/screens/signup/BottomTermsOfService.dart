import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import './termsofservice.dart';

class BottomTermsOfService extends StatelessWidget {
  const BottomTermsOfService({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'By creating an account, you agree to our ',
              style: TextStyle(
                  fontSize: 11, color: Colors.black, fontFamily: "Poppins"),
            ),
            TextSpan(
              text: 'Terms of Service',
              style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFFF30802),
                  fontFamily: "Poppins"),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TermsOfService()));
                },
            ),
            TextSpan(
              text: ' and ',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
            TextSpan(
              text: 'Privacy Policy',
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),
          ],
        ),
        textAlign: TextAlign.center, // Use textAlign if you need
      ),
    );
  }
}
