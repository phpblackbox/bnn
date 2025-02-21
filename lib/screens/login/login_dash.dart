import 'package:bnn/providers/auth_provider.dart';
import 'package:bnn/screens/login/email_login.dart';
import 'package:bnn/screens/login/phone_login.dart';
import 'package:bnn/screens/signup/signup_dash.dart';
import 'package:bnn/utils/colors.dart';
import 'package:bnn/widgets/sub/footer-tos.dart';
import 'package:bnn/widgets/sub/splash-logo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/buttons/button-gradient-primary.dart';
import '../../widgets/buttons/button-primary.dart';

class LoginDash extends StatefulWidget {
  const LoginDash({super.key});

  @override
  _LoginDashState createState() => _LoginDashState();
}

class _LoginDashState extends State<LoginDash>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryBlack, AppColors.primaryRed],
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
                        MaterialPageRoute(builder: (context) => SignUpDash()));
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
          SplashLogo(),

          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Login to BNN',
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
                    label: 'Email or username',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EmailLogin()),
                      );
                    },
                  ),
                  ButtonPrimary(
                    icon: Icons.phone,
                    label: 'Phone Login',
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PhoneLogin()));
                    },
                  ),
                  ButtonGradientPrimary(
                    icon: Icons.g_mobiledata_rounded,
                    label: 'Google Login',
                    textColor: Colors.white,
                    gradientColors: const [
                      AppColors.primaryBlack,
                      AppColors.primaryRed
                    ],
                    onPressed: () {
                      authProvider.googleSignIn(context);
                    },
                  ),
                  if (authProvider.isLoading)
                    const Center(child: CircularProgressIndicator()),
                  // if (authProvider.errorMessage != null)
                  //   Padding(
                  //     padding: const EdgeInsets.all(8.0),
                  //     child: Text(
                  //       authProvider.errorMessage!,
                  //       style: const TextStyle(color: Colors.red),
                  //       textAlign: TextAlign.center,
                  //     ),
                  //   ),
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
              );
            },
          ),

          FooterTOS(),
        ],
      ),
    );
  }
}
