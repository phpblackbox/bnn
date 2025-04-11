import 'package:bnn/screens/livestream/livestream_dash.dart';
import 'package:bnn/screens/home/notifications.dart';
import 'package:bnn/screens/profile/suggested.dart';
import 'package:bnn/screens/reel/reel.dart';
import 'package:flutter/material.dart';

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'assets/images/bnn_logo.png',
              height: 60,
            ),
            Row(
              children: [
                InkWell(
                  onTap: () async {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ReelScreen()));
                  },
                  child: Text(
                    '9:16s',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      height: 1.20,
                      letterSpacing: 0.50,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Suggested()));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.asset(
                      'assets/images/icons/profile_plus.png',
                      width: 20.0,
                      height: 20.0,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Notifications()));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.asset(
                      'assets/images/icons/notification_plus.png',
                      width: 20.0,
                      height: 20.0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}
