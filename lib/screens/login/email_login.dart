import 'package:bnn/providers/auth_provider.dart';
import 'package:bnn/screens/signup/signup_dash.dart';
import 'package:bnn/utils/colors.dart';
import 'package:bnn/widgets/buttons/button-gradient-main.dart';
import 'package:bnn/widgets/inputs/custom-input-field.dart';
import 'package:bnn/widgets/sub/splash-logo.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bnn/screens/login/email_login_otp_verification.dart';
import '../../widgets/sub/bottom-login.dart';

class EmailLogin extends StatefulWidget {
  const EmailLogin({super.key});

  @override
  _EmailLogin createState() => _EmailLogin();
}

class _EmailLogin extends State<EmailLogin>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    _checkingAuth = false;
  }

  bool _checkingAuth = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool get isButtonEnabled {
    return _emailController.text.isNotEmpty;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      isLoading = true;
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Make sure we're not already in the middle of an operation
      if (authProvider.isLoading) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      bool success = await authProvider.loginWithEmail(_emailController.text);

      if (success) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EmailLoginOTPVerification(
                email: _emailController.text,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          if (authProvider.errorMessage != null) {
            CustomToast.showToastWarningBottom(context, authProvider.errorMessage!);
          } else {
            CustomToast.showToastDangerBottom(context, 'An unexpected error occurred');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        CustomToast.showToastDangerBottom(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoggedIn && !_checkingAuth) {
    _checkingAuth = true;  // Set flag to prevent repeated calls
    
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   // Only sign out once and only if needed
    //   if (authProvider.isLoggedIn) {
    //     print('User already logged in on login page, signing out once');
    //     authProvider.signOut().then((_) {
    //       setState(() {
    //         _checkingAuth = false;  // Reset flag after signout completes
    //       });
    //     });
    //   } else {
    //     setState(() {
    //       _checkingAuth = false;  // Reset flag if no signout needed
    //     });
    //   }
    // });
  }

    return SafeArea(
      child: Scaffold(
        body: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: const [
                          AppColors.primaryBlack,
                          AppColors.primaryRed
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
                SplashLogo(),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
                              controller: _emailController,
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                            SizedBox(height: 16),
                            ButtonGradientMain(
                              label: isLoading ? 'Sending...' : 'Continue',
                              onPressed: isLoading ? () {} : () {
                                if (isButtonEnabled) {
                                  _login();
                                }
                              },
                              textColor: Colors.white,
                              gradientColors: isButtonEnabled
                                  ? [AppColors.primaryBlack, AppColors.primaryRed]
                                  : [
                                      AppColors.primaryRed.withOpacity(0.5),
                                      AppColors.primaryBlack.withOpacity(0.5)
                                    ],
                            ),
                            SizedBox(height: 10),
                            if (authProvider.isLoading)
                              const Center(child: CircularProgressIndicator()),
                            SizedBox(height: 10),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                BottomLogin(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}