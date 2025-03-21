import 'package:bnn/screens/chat/call_bottom.dart';
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'John Doe',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Duration: 12:34',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: 50),
          CircleAvatar(
            radius: 70,
            backgroundImage: AssetImage('assets/images/avatar/p2.png'),
          ),
          Spacer(),
          CallBottom(),
        ],
      ),
    );
  }
}
