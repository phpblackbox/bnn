import 'package:bnn/main.dart';
import 'package:bnn/screens/login/logindash.dart';
import 'package:bnn/screens/signup/createUsername.dart';
import 'package:bnn/screens/signup/phonesignup.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bnn/utils/constants.dart';
import './ButtonPrimary.dart';
import './ButtonGradientPrimary.dart';
import './emailSignUp.dart';
import './BottomTermsOfService.dart';

class SignUpDash extends StatefulWidget {
  const SignUpDash({super.key});

  @override
  _SignUpDash createState() => _SignUpDash();
}

class _SignUpDash extends State<SignUpDash>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    supabase.auth.onAuthStateChange.listen((data) {});

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

  Future<void> _nativeGoogleSignIn() async {
    const webClientId =
        '712940784971-vljjeta4ggrnq6ht63om5lob45q4efdl.apps.googleusercontent.com';

    const androidClientId =
        '712940784971-2alar2i0nnubhtqfk9pve1o8v7oncvb5.apps.googleusercontent.com';
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: androidClientId,
        serverClientId: webClientId,
      );

      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser!.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw 'No Access Token found.';
      }
      if (idToken == null) {
        throw 'No ID Token found.';
      }

      await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (supabase.auth.currentUser?.id != null) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => CreateUserName()));
      }
    } catch (error) {
      print('Error during Google sign-in: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Start a timer to navigate to the next page after 3 seconds

    return Container(
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
                    padding:
                        EdgeInsets.zero, // Remove padding as size is controlled
                    backgroundColor:
                        Colors.transparent, // Background transparent
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginDash()));
                  },
                  child: Text(
                    'LOG IN',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontFamily: "Poppins"),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 16),
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

          SizedBox(
            height: 16,
          ),

          SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Sign up for BNN',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Archivo',
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 20),
                  // Signup buttons with icons
                  ButtonPrimary(
                    icon: Icons.person,
                    label: 'Email Sign Up',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                EmailSignUp()), // Replace with your sign-in page widget
                      );
                    }, // Handle email signup
                  ),

                  ButtonPrimary(
                    icon: Icons.phone,
                    label: 'Phone Sign Up',
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PhoneSignUp()));
                    },
                  ),

                  ButtonGradientPrimary(
                    icon: Icons.g_mobiledata_rounded,
                    label: 'Google Sign Up',
                    textColor: Colors.white,
                    gradientColors: [
                      // Gradient colors
                      Color(0xFF000000),
                      Color(0xFF820200)
                    ],
                    // onPressed: _nativeGoogleSignIn,
                    onPressed: _nativeGoogleSignIn,
                  ),

                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Divider(color: Colors.black),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('or create account with',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.black,
                                  decoration: TextDecoration.none)),
                        ),
                        Expanded(
                          child: Divider(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 10),
          BottomTermsOfService(),
        ],
      ),
    );
  }
}
