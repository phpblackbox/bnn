import 'package:bnn/screens/signup/email_signup.dart';
import 'package:flutter/material.dart';
import 'package:bnn/utils/colors.dart';
import 'package:bnn/widgets/buttons/button-gradient-main.dart';
import 'package:bnn/widgets/inputs/custom-input-field.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:provider/provider.dart';
import 'package:bnn/providers/auth_provider.dart';

class PasswordResetVerification extends StatefulWidget {
  final String email;

  const PasswordResetVerification({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  _PasswordResetVerificationState createState() =>
      _PasswordResetVerificationState();
}

class _PasswordResetVerificationState extends State<PasswordResetVerification> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool isLoading = false;
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Reset Password",
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
                'We\'ve sent a verification code to your email',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              CustomInputField(
                icon: Icons.lock_outline,
                placeholder: 'Enter Verification Code',
                controller: _otpController,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {});
                },
              ),
              SizedBox(height: 20),
              CustomInputField(
                icon: Icons.lock_outline,
                placeholder: 'New Password',
                isPassword: true,
                controller: _newPasswordController,
                onChanged: (value) {
                  setState(() {});
                },
              ),
              SizedBox(height: 20),
              CustomInputField(
                icon: Icons.lock_outline,
                placeholder: 'Confirm New Password',
                isPassword: true,
                controller: _confirmPasswordController,
                onChanged: (value) {
                  setState(() {});
                },
              ),
              SizedBox(height: 20),
              ButtonGradientMain(
                label: 'Reset Password',
                onPressed: isLoading
                    ? () {}
                    : () async {
                        if (_otpController.text.isNotEmpty &&
                            _newPasswordController.text.isNotEmpty &&
                            _confirmPasswordController.text.isNotEmpty) {
                          if (_newPasswordController.text !=
                              _confirmPasswordController.text) {
                            CustomToast.showToastDangerBottom(
                                context, 'Passwords do not match');
                            return;
                          }
                          setState(() {
                            isLoading = true;
                          });
                          try {
                            final authProvider = Provider.of<AuthProvider>(
                                context,
                                listen: false);
                            bool status =
                                await authProvider.verifyPasswordResetOTP(
                              widget.email,
                              _otpController.text,
                              _newPasswordController.text,
                            );
                            if (status) {
                              CustomToast.showToastSuccessBottom(
                                  context, 'Password reset successfully');
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EmailSignUp(),
                                ),
                              );
                            } else {
                              CustomToast.showToastDangerBottom(
                                  context, 'Invalid OTP');
                            }
                          } catch (e) {
                            CustomToast.showToastDangerBottom(
                                context, e.toString());
                          } finally {
                            setState(() {
                              isLoading = false;
                            });
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
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() {
                          isLoading = true;
                        });
                        try {
                          final authProvider =
                              Provider.of<AuthProvider>(context, listen: false);
                          await authProvider.resetPassword(widget.email);
                          CustomToast.showToastSuccessBottom(
                              context, 'Verification code resent');
                        } catch (e) {
                          CustomToast.showToastDangerBottom(
                              context, e.toString());
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
    );
  }
}
