import 'package:bnn/widgets/sub/chat_view.dart';
import 'package:bnn/utils/colors.dart';
import 'package:bnn/widgets/buttons/button-gradient-main.dart';
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
                'Call Ended',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '14:23 minutes ',
                style: TextStyle(fontSize: 15, color: Color(0xFFF30802)),
              ),
            ],
          ),
          SizedBox(height: 20),
          CircleAvatar(
            radius: 60,
            backgroundImage: AssetImage('assets/images/avatar/p2.png'),
          ),
          Spacer(),
          ButtonGradientMain(
              label: 'Back to home',
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ChatView()));
              },
              textColor: Colors.white,
              gradientColors: [AppColors.primaryBlack, AppColors.primaryRed]),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}
