import 'dart:io';

import 'package:bnn/models/profiles.dart';
import 'package:bnn/screens/chat/ChatView.dart';
import 'package:bnn/screens/home/Reels.dart';
import 'package:bnn/screens/home/StorySlider.dart';
import 'package:bnn/screens/home/createPost.dart';
import 'package:bnn/screens/home/feedOrReels.dart';
import 'package:bnn/screens/home/header.dart';
import 'package:bnn/screens/home/postView.dart';
import 'package:bnn/screens/live/live.dart';
import 'package:bnn/screens/profile/profile.dart';
import 'package:bnn/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:bnn/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_supabase_chat_core/flutter_supabase_chat_core.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _feedorReels = 0; // 0: feed, 1; reels

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

  void _onFeedOrReel(int index) {
    setState(() {
      _feedorReels = index; // Update the selected index
    });
  }

  late FToast fToast;

  @override
  void initState() {
    super.initState();
    // If not logged in, navigate to the login screen
    print(supabase.auth.currentUser);
    supabase.auth.startAutoRefresh();

    if (supabase.auth.currentUser == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    fetchUser();
  }

  Future<void> fetchUser() async {
    if (supabase.auth.currentUser != null) {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        print('User is not logged in!');
        return;
      }

      try {
        final data =
            await supabase.from('profiles').select().eq("id", userId).single();

        if (data.isNotEmpty) {
          Constants().profile = Profiles(
            id: data['id'],
            firstName: data['first_name'],
            lastName: data['last_name'],
            username: data['username'],
            age: data['age'],
            bio: data['bio'],
            gender: data['gender'],
            avatar: data['avatar'],
          );

          Profiles profile = Profiles(
            id: data['id'],
            firstName: data['first_name'],
            lastName: data['last_name'],
            username: data['username'],
            age: data['age'],
            bio: data['bio'],
            gender: data['gender'],
            avatar: data['avatar'],
          );

          await Constants.saveProfile(profile);

          await SupabaseChatCore.instance.updateUser(
            types.User(
                firstName: data['first_name'],
                id: data['id'],
                lastName: data['last_name'],
                imageUrl: data['avatar']),
          );

          Profiles? loadedProfile = await Constants.loadProfile();
          if (loadedProfile != null) {
            print(
                'Loaded Profile: ${loadedProfile.firstName} ${loadedProfile.lastName}');
          } else {
            print('No profile found.');
            return;
          }
        }
      } catch (e) {
        print('Caught error: $e');
        if (e.toString().contains("JWT expired")) {
          await supabase.auth.signOut();
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Customize according to your theme
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60), // Set your desired height here
        child: Header(),
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 16, top: 0, right: 16),
        child: Column(
          children: [
            FeedOrReel(index: _feedorReels, onPressed: _onFeedOrReel),
            StorySlider(),
            if (_feedorReels == 0) PostView(),
            if (_feedorReels == 1) Reels(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
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
                    'assets/images/icons/home_active.png',
                    width: 20,
                    height: 20,
                  )),
              GestureDetector(
                  onTap: () => _onBottomNavigationTapped(1),
                  child: Image.asset(
                    'assets/images/icons/comment.png',
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
