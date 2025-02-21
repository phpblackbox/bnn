import 'package:bnn/screens/home/posts.dart';
import 'package:bnn/screens/profile/user_profile.dart';
import 'package:bnn/widgets/sub/chat_view.dart';
import 'package:bnn/screens/home/create_post.dart';
import 'package:bnn/screens/home/home.dart';
import 'package:bnn/screens/live/live.dart';
import 'package:bnn/screens/login/login_dash.dart';
import 'package:bnn/screens/profile/profile.dart';
import 'package:bnn/screens/signup/create_username.dart';
import 'package:bnn/screens/walkthrough/splash.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {
    '/': (context) => Splash(),
    '/login': (context) => LoginDash(),
    '/home': (context) => Home(),
    '/create-profile': (context) => CreateUserName(),
    '/chat': (context) => ChatView(),
    '/create-post': (context) => CreatePost(),
    '/live': (context) => Live(),
    '/profile': (context) => Profile(),
    '/posts': (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      return Posts(bookmark: args['bookmark'], userId: args['userId']);
    },
    '/user-profile': (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      return UserProfile(userId: args['userId']);
    },
  };
}
