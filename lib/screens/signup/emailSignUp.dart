import 'package:bnn/main.dart';
import 'package:bnn/screens/login/logindash.dart';
import 'package:bnn/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:bnn/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import './BottomTermsOfService.dart';
import './CustomInputField.dart';
import 'ButtonGradientMain.dart';
import './BottomLogin.dart';
import './createUserName.dart';

class EmailSignUp extends StatefulWidget {
  const EmailSignUp({super.key});

  @override
  _EmailSignUp createState() => _EmailSignUp();
}

class _EmailSignUp extends State<EmailSignUp>
    with SingleTickerProviderStateMixin {
  // for animation
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // for data
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

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
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty;
  }

  Future<void> _signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      CustomToast.showToastWarningBottom(context,
          'The passwords entered do not match. Let’s give it another try!');

      return;
    }
    if (_formKey.currentState!.validate()) {
      print(supabase.auth);
      setState(() {
        _isLoading = true;
      });

      try {
        final AuthResponse res = await supabase.auth.signUp(
          email: emailController.text.trim(),
          password: passwordController.text,
        );

        print(res);

        if (res.user != null) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => CreateUserName()));
        }
      } on AuthException catch (error) {
        CustomToast.showToastWarningBottom(context, error.message);
      } catch (error) {
        CustomToast.showToastDangerBottom(
            context, 'An unexpected error occurred');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Start a timer to navigate to the next page after 3 seconds

    return Scaffold(
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
              SizedBox(
                height: 16,
              ),
              SizedBox(
                height: 200,
                child: Center(
                  child: Image.asset(
                    'assets/images/splash_bnn_logo.png',
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
                          SizedBox(height: 10),
                          CustomInputField(
                            icon: Icons.lock,
                            placeholder: 'Confirm Password',
                            isPassword: true,
                            controller: confirmPasswordController,
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
              BottomTermsOfService(),

              ButtonGradientMain(
                label: 'Create account',
                onPressed: _signUp,
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
      ),
    );
  }
}
