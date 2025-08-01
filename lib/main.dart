import 'package:bnn/providers/auth_provider.dart';
import 'package:bnn/providers/livestream_provider.dart';
import 'package:bnn/providers/notification_provider.dart';
import 'package:bnn/providers/post_comment_provider.dart';
import 'package:bnn/providers/post_provider.dart';
import 'package:bnn/providers/profile_provider.dart';
import 'package:bnn/providers/reel_comment_provider.dart';
import 'package:bnn/providers/reel_provider.dart';
import 'package:bnn/providers/story_provider.dart';
import 'package:bnn/providers/story_view_provider.dart';
import 'package:bnn/providers/user_profile_provider.dart';
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
  await dotenv.load(fileName: ".env");
  await SupabaseService.initialize();
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
        ChangeNotifierProvider(create: (_) => ReelProvider()),
        ChangeNotifierProvider(create: (_) => ReelCommentProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProxyProvider<PostCommentProvider, PostProvider>(
          create: (_) => PostProvider(),
          update: (context, postCommentProvider, postProvider) {
            if (postCommentProvider.isSentMsg) {
              postProvider?.increaseCountComment(postCommentProvider.postId);
              postCommentProvider.isSentMsg = false;
            }

            if (postCommentProvider.isDeleteMsg) {
              postProvider?.deleteCountComment(postCommentProvider.postId);
              postCommentProvider.isDeleteMsg = false;
            }
            return postProvider!;
          },
        ),
        // ChangeNotifierProvider(create: (_) => LivestreamProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (state == AppLifecycleState.paused) {
      // App is in background
      authProvider.handleAppPause();
    } else if (state == AppLifecycleState.resumed) {
      // App is in foreground again
      authProvider.handleAppResume();
    }
  }

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
