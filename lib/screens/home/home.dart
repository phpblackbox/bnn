import 'dart:io';

import 'package:bnn/providers/auth_provider.dart';
import 'package:bnn/screens/story/story_slider.dart';
import 'package:bnn/widgets/sub/feed_or_reels.dart';
import 'package:bnn/screens/home/header.dart';
import 'package:bnn/screens/home/posts.dart';
import 'package:bnn/widgets/sub/bottom-navigation.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _feedorReels = 0; // 0: feed, 1; reels
  void _onFeedOrReel(int index) {
    setState(() {
      _feedorReels = index;
    });
  }

  var currentTime;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    if (authProvider.isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!authProvider.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
    }

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
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: EdgeInsets.only(left: 16, top: 0, right: 16),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 32, bottom: 0),
                child: Header(),
              ),
              FeedOrReel(index: _feedorReels, onPressed: _onFeedOrReel),
              StorySlider(),
              if (_feedorReels == 0) Posts(),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigation(currentIndex: 0),
      ),
    );
  }
}
