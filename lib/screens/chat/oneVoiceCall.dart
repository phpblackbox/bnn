import 'package:bnn/screens/chat/callBottom.dart';
import 'package:flutter/material.dart';

class OneVoiceCall extends StatefulWidget {
  const OneVoiceCall({super.key});

  @override
  _OneVoiceCallState createState() => _OneVoiceCallState();
}

class _OneVoiceCallState extends State<OneVoiceCall> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Name (Top Center)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'John Doe', // Replace with dynamic name
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Duration: 12:34', // Replace with dynamic duration
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: 50),
          // Avatar Image (Center of display)
          CircleAvatar(
            radius: 70,
            backgroundImage: AssetImage(
                'assets/images/avatar/p2.png'), // Replace with your image asset
          ),
          Spacer(),
          // Bottom Bar
          CallBottom(),
        ],
      ),
    );
  }
}
