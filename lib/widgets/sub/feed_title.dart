import 'package:flutter/material.dart';

class FeedTitle extends StatelessWidget {
  const FeedTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 16),
        Text(
          'Feed',
          style: TextStyle(
            color: Color(0xFFF30802),
            fontSize: 14,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            height: 1.20,
            letterSpacing: 0.50,
          ),
        ),
      ],
    );
  }
}
