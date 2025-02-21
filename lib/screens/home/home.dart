import 'package:bnn/providers/auth_provider.dart';
import 'package:bnn/screens/home/reels.dart';
import 'package:bnn/screens/home/story_slider.dart';
import 'package:bnn/widgets/sub/feed_or_reels.dart';
import 'package:bnn/screens/home/header.dart';
import 'package:bnn/screens/home/posts.dart';
import 'package:bnn/widgets/sub/bottom-navigation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final supabase = Supabase.instance.client;

  int _feedorReels = 0; // 0: feed, 1; reels
  void _onFeedOrReel(int index) {
    setState(() {
      _feedorReels = index;
    });
  }

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

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(90),
          child: Container(
            margin: EdgeInsets.only(top: 30),
            child: Header(),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(left: 16, top: 0, right: 16),
          child: Column(
            children: [
              FeedOrReel(index: _feedorReels, onPressed: _onFeedOrReel),
              StorySlider(),
              if (_feedorReels == 0) Posts(),
              if (_feedorReels == 1) Reels(),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigation(currentIndex: 0));
  }
}
