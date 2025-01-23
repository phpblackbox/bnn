import 'package:flutter/material.dart';

class InputWithEmoji extends StatefulWidget {
  const InputWithEmoji({super.key});

  @override
  _InputWithEmojiState createState() => _InputWithEmojiState();
}

class _InputWithEmojiState extends State<InputWithEmoji> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      style: TextStyle(
        fontSize: 10.0,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        hintText: 'Add a comment...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        suffixIcon: Container(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {},
                child: ImageIcon(
                  AssetImage('assets/images/icons/mention.png'),
                  color: Color(0xFF4D4C4A),
                  size: 20,
                ),
              ),
              SizedBox(width: 10),
              GestureDetector(
                onTap: () {},
                child: ImageIcon(
                  AssetImage('assets/images/icons/emoji.png'),
                  color: Color(0xFF4D4C4A),
                  size: 20,
                ),
              ),
              SizedBox(width: 10),
            ],
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        filled: true,
        fillColor: Color(0xFFE9E9E9),
        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      ),
    );
  }
}
