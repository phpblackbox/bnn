import 'package:bnn/screens/chat/call_end.dart';
import 'package:flutter/material.dart';

class CallBottom extends StatefulWidget {
  const CallBottom({super.key});

  @override
  _CallBottomState createState() => _CallBottomState();
}

class _CallBottomState extends State<CallBottom> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Color(0xFF800000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
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
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.video_camera_back_rounded, color: Colors.white),
              onPressed: () {},
            ),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFFF2121),
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
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.add_reaction_outlined, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
