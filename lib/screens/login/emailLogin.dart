import 'package:bnn/main.dart';
import 'package:bnn/models/profiles.dart';
import 'package:bnn/screens/signup/signupDash.dart';
import 'package:bnn/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:bnn/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './BottomLogin.dart';
import '../signup/CustomInputField.dart';
import '../signup/ButtonGradientMain.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_supabase_chat_core/flutter_supabase_chat_core.dart';

class EmailLogin extends StatefulWidget {
  const EmailLogin({super.key});

  @override
  _EmailLogin createState() => _EmailLogin();
}

class _EmailLogin extends State<EmailLogin>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.5), end: Offset(0, 0))
        .animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    // Start the animation
    _controller.forward();
  }

  bool get isButtonEnabled {
    return emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty;
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

  Future<void> _login() async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      if (response.user != null) {
        fetchUser();
        Navigator.pushReplacementNamed(context, '/home');
        CustomToast.showToastSuccessTop(context, "Welcome to BNN");
      }
    } on AuthException catch (error) {
      CustomToast.showToastWarningBottom(context, error.message);
    } catch (error) {
      CustomToast.showToastDangerBottom(
          context, 'An unexpected error occurred');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Start a timer to navigate to the next page after 3 seconds

    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Log IN button
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF101013), // First color
                      Color(0xFF8D0000), // Second color
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: SizedBox(
                  width: 80, // Set the width of the button
                  height: 30, // Set the height of the button
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets
                          .zero, // Remove padding as size is controlled
                      backgroundColor:
                          Colors.transparent, // Background transparent
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUpDash()));
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),

            // Logo image
            SizedBox(
              height: 16,
            ),

            SizedBox(
              height: 200,
              child: Center(
                child: Image.asset(
                  'assets/images/splash_bnn_logo.png', // Replace with your logo asset
                  height: 200, // Adjust height as necessary
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Email Sign Up
                    Text(
                      'Email or username',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Archivo',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Column(
                      children: [
                        CustomInputField(
                          icon: Icons.email,
                          placeholder: 'Email or username',
                          controller: emailController,
                          onChanged: (value) {
                            setState(
                                () {}); // Update state on email field change
                          },
                        ),
                        SizedBox(height: 10),
                        CustomInputField(
                          icon: Icons.lock,
                          placeholder: 'Password',
                          isPassword: true,
                          controller: passwordController,
                          onChanged: (value) {
                            setState(
                                () {}); // Update state on email field change
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            ButtonGradientMain(
              label: 'Log in',
              onPressed: () {
                if (isButtonEnabled) {
                  _login();
                }
              },
              textColor: Colors.white,
              gradientColors: isButtonEnabled
                  ? [Color(0xFF000000), Color(0xFF820200)] // Active gradient
                  : [
                      Color(0xFF820200).withOpacity(0.5),
                      Color(0xFF000000).withOpacity(0.5)
                    ],
            ),

            BottomLogin(),
          ],
        ),
      ),
    );
  }
}
