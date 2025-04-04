import 'package:bnn/screens/reel/reel.dart';
import 'package:flutter/material.dart';

class FeedOrReel extends StatelessWidget {
  final int index;
  final Function(int) onPressed;

  const FeedOrReel({super.key, required this.index, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (index == 0)
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF30802),
            ),
          ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => onPressed(0),
          child: Text(
            'Feed',
            style: TextStyle(
              color: index == 0 ? Color(0xFFF30802) : Colors.black,
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              height: 1.20,
              letterSpacing: 0.50,
            ),
          ),
        ),
        const SizedBox(width: 16),
        if (index == 1)
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF30802),
            ),
          ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () async {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => ReelScreen()));
          },
          child: Text(
            '9:16s',
            style: TextStyle(
              color: index == 1 ? Color(0xFFF30802) : Colors.black,
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              height: 1.20,
              letterSpacing: 0.50,
            ),
          ),
        ),
      ],
    );
  }
}
