import 'package:flutter/material.dart';
import 'package:bnn/providers/auth_provider.dart';
import 'package:bnn/utils/colors.dart';
import 'package:bnn/widgets/buttons/button-gradient-main.dart';
import 'package:bnn/widgets/inputs/custom-input-field.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:provider/provider.dart';

class EmailLoginOTPVerification extends StatefulWidget {
  final String email;

  const EmailLoginOTPVerification({
    Key? key, 
    required this.email,
  }) : super(key: key);

  @override
  _EmailLoginOTPVerificationState createState() => _EmailLoginOTPVerificationState();
}

class _EmailLoginOTPVerificationState extends State<EmailLoginOTPVerification> {
  final TextEditingController otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Verify Email",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Enter Verification Code',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Archivo',
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  'We\'ve sent a verification code to:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  widget.email,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                CustomInputField(
                  icon: Icons.lock_outline,
                  placeholder: 'Enter verification code',
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                SizedBox(height: 20),
                ButtonGradientMain(
                  label: 'Verify & Login',
                  onPressed: isLoading ? () {} : () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        isLoading = true;
                      });

                      try {
                        final authProvider = Provider.of<AuthProvider>(
                            context, listen: false);
                        
                        // Check if already loading
                        if (authProvider.isLoading) {
                          setState(() {
                            isLoading = false;
                          });
                          return;
                        }

                        bool status = await authProvider.verifyEmailLoginOTP(
                          widget.email,
                          otpController.text,
                        );

                        if (status) {
                          if (mounted) {
                            if (authProvider.profile == null) {
                              // No profile exists, redirect to create profile
                              CustomToast.showToastWarningTop(
                                  context, "Please complete your profile setup");
                              Navigator.pushReplacementNamed(context, '/create-profile');
                            } else {
                              // Profile exists, go to home
                              CustomToast.showToastSuccessTop(
                                  context, "Welcome to BNN");
                              Navigator.pushReplacementNamed(context, '/home');
                            }
                          }
                        } else if (mounted) {
                          CustomToast.showToastDangerBottom(
                              context, authProvider.errorMessage ?? 'Invalid OTP');
                        }
                      } catch (e) {
                        if (mounted) {
                          print('OTP verification error: $e');
                          CustomToast.showToastDangerBottom(
                              context, e.toString());
                        }
                      } finally {
                        if (mounted) {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      }
                    }
                  },
                  textColor: Colors.white,
                  gradientColors: [
                    AppColors.primaryBlack,
                    AppColors.primaryRed,
                  ],
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: isLoading ? () {} : () async {
                    setState(() {
                      isLoading = true;
                    });
                    try {
                      final authProvider =
                          Provider.of<AuthProvider>(context, listen: false);
                      
                      await authProvider.loginWithEmail(widget.email);
                      CustomToast.showToastSuccessBottom(
                          context, 'Verification code resent!');
                    } catch (e) {
                      CustomToast.showToastDangerBottom(context, e.toString());
                    } finally {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                  child: Text(
                    'Resend Code',
                    style: TextStyle(
                      color: AppColors.primaryRed,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}