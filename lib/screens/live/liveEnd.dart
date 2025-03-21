import 'package:bnn/screens/home/home.dart';
import 'package:flutter/material.dart';

class liveEnd extends StatefulWidget {
  const liveEnd({super.key});

  @override
  _liveEndState createState() => _liveEndState();
}

class _liveEndState extends State<liveEnd> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/call4.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Live Performance Ended',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '14:23 minutes ',
                      style: TextStyle(
                        color: Color(0xFFF30802),
                        fontSize: 10,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  ],
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: 90,
                  height: 90,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage('assets/images/avatar/p3.png'),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'You Ended The On Air session',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'Source Sans Pro',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Home()),
                    );
                  },
                  child: Container(
                    width: 250,
                    height: 56,
                    decoration: ShapeDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Back to home',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        height: 1.50,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
