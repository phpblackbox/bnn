import 'package:bnn/screens/chat/GroupList.dart';
import 'package:bnn/screens/chat/chatList.dart';
import 'package:bnn/screens/home/createPost.dart';
import 'package:bnn/screens/home/home.dart';
import 'package:bnn/screens/live/live.dart';
import 'package:bnn/screens/profile/profile.dart';
import './ChatOrGroup.dart';
import 'package:flutter/material.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  int _ChatViewOrGroup = 0; // 0: feed, 1; reels

  void _onBottomNavigationTapped(int index) {
    if (index == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
    }
    if (index == 1) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ChatView()));
    }
    if (index == 2) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreatePost()));
    }
    if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Live()));
    }
    if (index == 4) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Profile()));
    }
  }

  void _onChatViewOrGroup(int index) {
    setState(() {
      _ChatViewOrGroup = index; // Update the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Customize according to your theme

      body: Padding(
        padding: EdgeInsets.only(left: 16, top: 32, right: 16),
        child: Column(children: [
          ChatOrGroup(index: _ChatViewOrGroup, onPressed: _onChatViewOrGroup),
          SizedBox(height: 15),
          if (_ChatViewOrGroup == 0) ChatList(),
          if (_ChatViewOrGroup == 1) GroupList(),
        ]),
      ),
      bottomNavigationBar: SizedBox(
        height: 67.0,
        child: Padding(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                  onTap: () => _onBottomNavigationTapped(0),
                  child: Image.asset(
                    'assets/images/icons/home.png',
                    width: 20,
                    height: 20,
                  )),
              GestureDetector(
                  onTap: () => _onBottomNavigationTapped(1),
                  child: Image.asset(
                    'assets/images/icons/comment_active.png',
                    width: 20,
                    height: 20,
                  )),
              GestureDetector(
                onTap: () => _onBottomNavigationTapped(2),
                child: Image.asset(
                  'assets/images/navigation_add_post.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              GestureDetector(
                  onTap: () => _onBottomNavigationTapped(3),
                  child: Image.asset(
                    'assets/images/icons/video.png',
                    width: 20,
                    height: 20,
                  )),
              GestureDetector(
                  onTap: () => _onBottomNavigationTapped(4),
                  child: Image.asset(
                    'assets/images/icons/user.png',
                    width: 20,
                    height: 20,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
