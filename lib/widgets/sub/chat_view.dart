import 'dart:io';

import 'package:bnn/screens/chat/group_list.dart';
import 'package:bnn/screens/chat/chat_list.dart';
import 'package:bnn/widgets/sub/bottom-navigation.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:flutter/services.dart';
import '../../screens/chat/chat_or_group.dart';
import 'package:flutter/material.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  int _ChatViewOrGroup = 0;
  void _onChatViewOrGroup(int index) {
    setState(() {
      _ChatViewOrGroup = index;
    });
  }

  var currentTime;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        DateTime now = DateTime.now();
        if (currentTime == null ||
            now.difference(currentTime) > const Duration(seconds: 2)) {
          currentTime = now;
          CustomToast.showToastWarningTop(context, "Press agian to exit");
          return Future.value(false);
        } else {
          SystemNavigator.pop();
          exit(0);
          // Future.value(false);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: EdgeInsets.only(left: 16, top: 48, right: 16),
          child: Column(children: [
            ChatOrGroup(index: _ChatViewOrGroup, onPressed: _onChatViewOrGroup),
            SizedBox(height: 15),
            if (_ChatViewOrGroup == 0) ChatList(),
            if (_ChatViewOrGroup == 1) GroupList(),
          ]),
        ),
        bottomNavigationBar: BottomNavigation(currentIndex: 1),
      ),
    );
  }
}
