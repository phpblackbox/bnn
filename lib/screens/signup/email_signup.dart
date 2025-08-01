import 'package:bnn/providers/auth_provider.dart';
import 'package:bnn/screens/login/login_dash.dart';
import 'package:bnn/utils/colors.dart';
import 'package:bnn/widgets/buttons/button-gradient-main.dart';
import 'package:bnn/widgets/inputs/custom-input-field.dart';
import 'package:bnn/widgets/sub/footer-tos.dart';
import 'package:bnn/widgets/sub/splash-logo.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/sub/bottom-signup.dart';
import '../../screens/signup/email_otp_verification.dart';

class EmailSignUp extends StatefulWidget {
  const EmailSignUp({super.key});
  @override
  _EmailSignUpState createState() => _EmailSignUpState();
}

class _EmailSignUpState extends State<EmailSignUp>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  bool get isButtonEnabled {
    return emailController.text.isNotEmpty;
  }

  Future<void> _signUp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    setState(() {
      isLoading = true;
    });

    if (_formKey.currentState!.validate()) {
      try {
        bool success = await authProvider.signUpWithEmail(
          emailController.text,
          context,
        );

        if (success) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => EmailOTPVerification(
                email: emailController.text,
              ),
            ),
          );
        } else {
          if (authProvider.errorMessage != null) {
            CustomToast.showToastWarningBottom(
                context, authProvider.errorMessage!);
          } else {
            CustomToast.showToastDangerBottom(
                context, 'An unexpected error occurred');
          }
        }
      } catch (e) {
        CustomToast.showToastDangerBottom(context, e.toString());
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginDash()));
                        },
                        child: Text(
                          'LOG IN',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontFamily: 'Poppins'),
                        ),
                      ),
                    ),
                  ),
                ),
                SplashLogo(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Email Sign Up',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        decoration: TextDecoration.none,
                        fontFamily: 'Archivo',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Column(
                      children: [
                        CustomInputField(
                            icon: Icons.email,
                            placeholder: 'Enter your Email',
                            controller: emailController,
                            onChanged: (value) {
                              setState(() {});
                            }),
                        SizedBox(height: 10),
                        // Removed password fields
                      ],
                    ),
                  ],
                ),
                FooterTOS(),
                ButtonGradientMain(
                  label: isLoading ? 'Sending...' : 'Continue',
                  onPressed: isLoading ? () {} : () {
                    if (isButtonEnabled) {
                      _signUp();
                    }
                  },
                  textColor: Colors.white,
                  gradientColors: isButtonEnabled && !isLoading
                      ? [AppColors.primaryBlack, AppColors.primaryRed]
                      : [
                          AppColors.primaryRed.withOpacity(0.5),
                          AppColors.primaryBlack.withOpacity(0.5)
                        ],
                ),
                // BottomSignUp(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}