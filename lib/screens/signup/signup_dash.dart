import 'package:bnn/providers/auth_provider.dart';
import 'package:bnn/screens/login/login_dash.dart';
import 'package:bnn/screens/signup/phone_signup.dart';
import 'package:bnn/utils/colors.dart';
import 'package:bnn/widgets/buttons/button-gradient-primary.dart';
import 'package:bnn/widgets/buttons/button-primary.dart';
import 'package:bnn/widgets/sub/footer-tos.dart';
import 'package:bnn/widgets/sub/splash-logo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'email_signup.dart';

class SignUpDash extends StatefulWidget {
  const SignUpDash({super.key});

  @override
  _SignUpDashState createState() => _SignUpDashState();
}

class _SignUpDashState extends State<SignUpDash>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();

    supabase.auth.onAuthStateChange.listen((data) {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF101013),
                      Color(0xFF8D0000),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: SizedBox(
                  width: 80,
                  height: 30,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.transparent,
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
            SplashLogo(),
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return Column(
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
                    ButtonPrimary(
                      icon: Icons.person,
                      label: 'Email Sign Up',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EmailSignUp()),
                        );
                      },
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
                        AppColors.primaryBlack,
                        AppColors.primaryRed
                      ],
                      onPressed: () {
                        authProvider.googleSignIn(context);
                      },
                    ),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Divider(color: Colors.black),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
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
                );
              },
            ),
            FooterTOS(),
          ],
        ),
      ),
    );
  }
}
