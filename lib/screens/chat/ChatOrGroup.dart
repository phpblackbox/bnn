import 'package:flutter/material.dart';

class ChatOrGroup extends StatelessWidget {
  final int index;
  final Function(int) onPressed;

  const ChatOrGroup({super.key, required this.index, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 8),
        InkWell(
          onTap: () => onPressed(0),
          child: Text(
            'Chats',
            style: TextStyle(
              color: index == 0 ? Color(0xFF4D4C4A) : Color(0x884D4C4A),
              fontSize: 20,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          ' | ',
          style: TextStyle(
            color: Color(0xFF4D4C4A),
            fontSize: 20,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
          ),
        ),
        InkWell(
          onTap: () => onPressed(1),
          child: Text(
            'Groups',
            style: TextStyle(
              color: index == 1 ? Color(0xFF4D4C4A) : Color(0x884D4C4A),
              fontSize: 20,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
