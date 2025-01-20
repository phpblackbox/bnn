import 'package:bnn/utils/constants.dart';
import 'package:bnn/screens/home/notifications.dart';
import 'package:bnn/screens/profile/suggested.dart';
import 'package:flutter/material.dart';

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            Constants.logo,
            height: 140,
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {},
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                  child: Image.asset(
                    'assets/images/icons/live.png', // Path to your image
                    width: 20.0,
                    height: 20.0,
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
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                  child: Image.asset(
                    'assets/images/icons/profile_plus.png', // Path to your image
                    width: 20.0,
                    height: 20.0,
                  ),
                ),
              ),
              SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Notifications()));
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                  child: Image.asset(
                    'assets/images/icons/notification_plus.png', // Path to your image
                    width: 20.0,
                    height: 20.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
