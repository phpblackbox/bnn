import 'package:bnn/screens/login/account_recovery.dart';
import 'package:bnn/screens/signup/signup_dash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class BottomLogin extends StatelessWidget {
  const BottomLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Don't have an account?  ",
                style: TextStyle(fontSize: 12, color: Colors.black),
              ),
              TextSpan(
                text: 'Sign Up',
                style: TextStyle(fontSize: 12, color: Color(0xFFF30802)),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SignUpDash()));
                  },
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 5),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AccountRecovery()),
            );
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => PasswordResetVerification(
            //       email: _emailController.text,
            //     ),
            //   ),
            // );
          },
          child: Text(
            'Trouble Signing in?',
            style: TextStyle(fontSize: 12, color: Color(0xFFF30802)),
          ),
        ),
      ]),
    );
  }
}
