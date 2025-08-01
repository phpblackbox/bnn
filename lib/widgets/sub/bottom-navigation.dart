import 'dart:io';

import 'package:bnn/providers/auth_provider.dart';
import 'package:bnn/screens/reel/reel.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;

  const BottomNavigation({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  static const icons = {
    "home": [
      'assets/images/icons/home.png',
      'assets/images/icons/home_active.png',
    ],
    "comment": [
      'assets/images/icons/comment.png',
      'assets/images/icons/comment_active.png',
    ],
    "video": [
      'assets/images/icons/video.png',
      'assets/images/icons/video_active.png',
    ],
    "user": [
      'assets/images/icons/user.png',
      'assets/images/icons/user_active.png',
    ],
  };

  Future<void> onTabSelected(BuildContext context, int index) async {
    if (currentIndex == index) return;
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/chat');
        break;
      case 2:
        Navigator.pushNamed(context, '/create-post');
        break;
      case 3:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ReelScreen()));
        break;
      case 4:
        // final authProvider = Provider.of<AuthProvider>(context, listen: false);
        // if (authProvider.profile == null) {
        //   // Redirect to create profile if profile is null
        //   // Don't auto-logout here
        //   Navigator.pushReplacementNamed(context, '/create-profile');
        //   CustomToast.showToastWarningTop(
        //       context, "Please complete your profile setup first");
        // } else {
        //   // Normal navigation
        //   Navigator.pushReplacementNamed(context, '/profile');
        // }
        // Single Responsibility Principle: The profile page should be responsible for handling profile-related logic, including whether the profile exists.
        Navigator.pushReplacementNamed(context, '/profile');
        break;
      default:
        Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Platform.isIOS ? 90 : 67.0,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _buildIconButton(
                context, icons["home"]![currentIndex == 0 ? 1 : 0], 0),
            _buildIconButton(
                context, icons["comment"]![currentIndex == 1 ? 1 : 0], 1),
            _buildIconButton(
              context,
              'assets/images/navigation_add_post.png',
              2,
              isMainAction: true,
            ),
            _buildIconButton(
                context, icons["video"]![currentIndex == 3 ? 1 : 0], 3),
            _buildIconButton(
                context, icons["user"]![currentIndex == 4 ? 1 : 0], 4),
          ],
        ),
      ),
    );
  }

  GestureDetector _buildIconButton(
      BuildContext context, String assetPath, int index,
      {bool isMainAction = false}) {
    return GestureDetector(
      onTap: () => onTabSelected(context, index),
      child: Image.asset(
        assetPath,
        width: Platform.isIOS
            ? (isMainAction ? 100 : 26)
            : (isMainAction ? 80 : 20),
        height: Platform.isIOS
            ? (isMainAction ? 100 : 26)
            : (isMainAction ? 80 : 20),
        fit: isMainAction ? BoxFit.cover : null,
      ),
    );
  }
}
