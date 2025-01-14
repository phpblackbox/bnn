import 'package:bnn/screens/chat/callEnd.dart';
import 'package:flutter/material.dart';

class CallBottom extends StatefulWidget {
  const CallBottom({Key? key}) : super(key: key);

  @override
  _CallBottomState createState() => _CallBottomState();
}

class _CallBottomState extends State<CallBottom> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black,
            Color(0xFF800000)
          ], // Set your gradient colors here
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20), // Set top-left radius
          topRight: Radius.circular(20), // Set top-right radius
        ),
      ),
      child: BottomAppBar(
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(
                Icons.change_circle_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                // Re-dial action
              },
            ),
            IconButton(
              icon: Icon(Icons.video_camera_back_rounded, color: Colors.white),
              onPressed: () {
                // Video call action
              },
            ),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFFF2121), // Background color
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: IconButton(
                icon: const Icon(Icons.call_end, color: Colors.white),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => callEnd()));
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.mic, color: Colors.white),
              onPressed: () {
                // Voice action
              },
            ),
            IconButton(
              icon: Icon(Icons.add_reaction_outlined, color: Colors.white),
              onPressed: () {
                // Emoji action
              },
            ),
          ],
        ),
      ),
    );
  }
}
