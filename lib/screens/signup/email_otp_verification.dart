import 'package:flutter/material.dart';
import 'package:bnn/providers/auth_provider.dart';
import 'package:bnn/utils/colors.dart';
import 'package:bnn/widgets/buttons/button-gradient-main.dart';
import 'package:bnn/widgets/inputs/custom-input-field.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:provider/provider.dart';

class EmailOTPVerification extends StatefulWidget {
  final String email;

  const EmailOTPVerification({Key? key, required this.email}) : super(key: key);

  @override
  _EmailOTPVerificationState createState() => _EmailOTPVerificationState();
}

class _EmailOTPVerificationState extends State<EmailOTPVerification> {
  final TextEditingController otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Verify Your Email',
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
                  label: 'Verify Email',
                  onPressed: isLoading
                      ? () {}
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              isLoading = true;
                            });
                            try {
                              final authProvider = Provider.of<AuthProvider>(
                                  context,
                                  listen: false);
                              bool status = await authProvider.verifyEmailOTP(
                                widget.email,
                                otpController.text,
                              );

                              if (status) {
                                Navigator.pushReplacementNamed(
                                    context, '/create-profile');
                              } else {
                                CustomToast.showToastDangerBottom(
                                    context, authProvider.errorMessage);
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
                  onPressed: () async {
                    try {
                      final authProvider =
                          Provider.of<AuthProvider>(context, listen: false);
                      await authProvider.resendEmailOTP(widget.email);
                      CustomToast.showToastSuccessBottom(
                          context, 'Verification code resent!');
                    } catch (e) {
                      CustomToast.showToastDangerBottom(context, e.toString());
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
