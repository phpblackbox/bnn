import 'package:bnn/screens/login/loginDash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class BottomLogin extends StatelessWidget {
  const BottomLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Already have an account?   ',
              style: TextStyle(
                  fontSize: 12, color: Colors.black, fontFamily: "Poppins"),
            ),
            TextSpan(
              text: 'Log In',
              style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFFF30802),
                  fontFamily: "Poppins"),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginDash()));
                },
            ),
          ],
        ),
        textAlign: TextAlign.center, // Use textAlign if you need
      ),
    );
  }
}
