import 'package:bnn/screens/chat/callBottom.dart';
import 'package:flutter/material.dart';

class OneVideoCall extends StatefulWidget {
  const OneVideoCall({super.key});

  @override
  _OneVideoCallState createState() => _OneVideoCallState();
}

class _OneVideoCallState extends State<OneVideoCall> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/call1.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
            bottom: 120,
            right: 10,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color(0xFFF30802),
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Image.asset(
                'assets/images/call2.png',
                height: 150,
              ),
            )),
      ]),
      bottomNavigationBar: CallBottom(),
    );
  }
}
