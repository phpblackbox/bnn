import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'routes/app_routes.dart';
import 'dart:io';

Future<void> ensureSession() async {
  supabase.auth.startAutoRefresh();
}

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://prrbylvucoyewsezqcjn.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBycmJ5bHZ1Y295ZXdzZXpxY2puIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ4OTI2NTQsImV4cCI6MjA1MDQ2ODY1NH0.x8WeQI2hxqrgSa7ERSE7e1ROOCBRVemEY9VhMoD_JAY',
  );

  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'bnn',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: AppRoutes.routes,
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => NotFoundScreen());
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins', // Set your custom font family here
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 16.0, color: Colors.black),
          bodyMedium: TextStyle(fontSize: 14.0, color: Colors.black),
          displayLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          // Add more styles as needed
        ),
      ),
    );
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Not Found')),
      body: Center(child: Text('404 - Page Not Found')),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
