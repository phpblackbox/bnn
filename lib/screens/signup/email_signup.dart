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

class EmailSignUp extends StatefulWidget {
  const EmailSignUp({super.key});
  @override
  _EmailSignUpState createState() => _EmailSignUpState();
}

class _EmailSignUpState extends State<EmailSignUp>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;

  // for data
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool get isButtonEnabled {
    return emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty;
  }

  Future<void> _signUp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_formKey.currentState!.validate()) {
      bool success = await authProvider.signUp(
        emailController.text,
        passwordController.text,
        confirmPasswordController.text,
        context,
      );

      if (success) {
        Navigator.pushReplacementNamed(context, '/create-profile');
      } else {
        if (authProvider.errorMessage != null) {
          CustomToast.showToastWarningBottom(
              context, authProvider.errorMessage!);
        } else {
          CustomToast.showToastDangerBottom(
              context, 'An unexpected error occurred');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Start a timer to navigate to the next page after 3 seconds

    return SafeArea(
      child: Scaffold(
        body: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
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

                // Logo image
                SplashLogo(),

                Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Email Sign Up
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
                        CustomInputField(
                            icon: Icons.lock,
                            placeholder: 'Password',
                            isPassword: true,
                            controller: passwordController,
                            onChanged: (value) {
                              setState(() {});
                            }),
                        SizedBox(height: 10),
                        CustomInputField(
                            icon: Icons.lock,
                            placeholder: 'Confirm Password',
                            isPassword: true,
                            controller: confirmPasswordController,
                            onChanged: (value) {
                              setState(() {});
                            }),
                      ],
                    ),
                  ],
                ),
                FooterTOS(),

                ButtonGradientMain(
                  label: 'Create account',
                  onPressed: () {
                    if (isButtonEnabled) {
                      _signUp();
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

                BottomSignUp(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
