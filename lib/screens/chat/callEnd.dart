import 'package:bnn/screens/chat/ChatView.dart';
import 'package:bnn/screens/signup/ButtonGradientMain.dart';
import 'package:flutter/material.dart';

class callEnd extends StatefulWidget {
  const callEnd({super.key});

  @override
  _callEndState createState() => _callEndState();
}

class _callEndState extends State<callEnd> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 50),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Call Ended', // Replace with dynamic name
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '14:23 minutes ', // Replace with dynamic duration
                style: TextStyle(fontSize: 15, color: Color(0xFFF30802)),
              ),
            ],
          ),
          SizedBox(height: 20),
          // Avatar Image (Center of display)
          CircleAvatar(
            radius: 60,
            backgroundImage: AssetImage(
                'assets/images/avatar/p2.png'), // Replace with your image asset
          ),
          Spacer(),
          // Bottom Bar
          ButtonGradientMain(
              label: 'Back to home',
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ChatView()));
              },
              textColor: Colors.white,
              gradientColors: [
                Color(0xFF000000),
                Color(0xFF820200)
              ] // Active gradient

              ),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}
