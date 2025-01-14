import 'package:bnn/screens/home/home.dart';
import 'package:bnn/screens/login/loginDash.dart';
import 'package:bnn/screens/walkthrough/splash.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {
    '/': (context) => Splash(),
    '/login': (context) => LoginDash(),
    '/home': (context) => Home(),
  };
}
