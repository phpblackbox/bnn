import 'package:bnn/providers/auth_provider.dart';
import 'package:bnn/providers/notification_provider.dart';
import 'package:bnn/providers/post_comment_provider.dart';
import 'package:bnn/providers/post_provider.dart';
import 'package:bnn/providers/story_provider.dart';
import 'package:bnn/providers/story_view_provider.dart';
import 'package:bnn/services/supabase_client.dart';
import 'package:bnn/widgets/sub/not-found-404.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'routes/app_routes.dart';
import 'dart:io';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  await dotenv.load(fileName: ".env");
  HttpOverrides.global = MyHttpOverrides();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StoryProvider()),
        ChangeNotifierProvider(create: (_) => StoryViewProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => PostCommentProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

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
