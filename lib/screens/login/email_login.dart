import 'package:bnn/providers/auth_provider.dart';
import 'package:bnn/screens/signup/signup_dash.dart';
import 'package:bnn/utils/colors.dart';
import 'package:bnn/widgets/buttons/button-gradient-main.dart';
import 'package:bnn/widgets/inputs/custom-input-field.dart';
import 'package:bnn/widgets/sub/splash-logo.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/sub/bottom-login.dart';

class EmailLogin extends StatefulWidget {
  const EmailLogin({super.key});

  @override
  _EmailLogin createState() => _EmailLogin();
}

class _EmailLogin extends State<EmailLogin>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get isButtonEnabled {
    return _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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

              // Logo image
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
                          SizedBox(height: 10),
                          CustomInputField(
                              icon: Icons.lock,
                              placeholder: 'Password',
                              isPassword: true,
                              controller: _passwordController,
                              onChanged: (value) {
                                setState(() {});
                              }),
                          SizedBox(height: 16),
                          
                          ButtonGradientMain(
                            label: 'Log in',
                            onPressed: () async {
                              if (isButtonEnabled) {
                                bool success = await authProvider
                                    .loginWithEmailAndPassword(
                                  _emailController.text,
                                  _passwordController.text,
                                  context,
                                );

                                if (success) {
                                  CustomToast.showToastSuccessTop(
                                      context, "Welcome to BNN");
                                } else {
                                  if (authProvider.errorMessage != null) {
                                    CustomToast.showToastWarningBottom(
                                        context, authProvider.errorMessage!);
                                  } else {
                                    CustomToast.showToastDangerBottom(context,
                                        'An unexpected error occurred');
                                  }
                                }
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
    );
  }
}
