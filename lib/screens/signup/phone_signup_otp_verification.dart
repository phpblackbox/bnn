import 'package:flutter/material.dart';
import 'package:bnn/providers/auth_provider.dart';
import 'package:bnn/utils/colors.dart';
import 'package:bnn/widgets/buttons/button-gradient-main.dart';
import 'package:bnn/widgets/inputs/custom-input-field.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class PhoneSignupOTPVerification extends StatefulWidget {
  final String phone;

  const PhoneSignupOTPVerification({Key? key, required this.phone}) : super(key: key);

  @override
  _PhoneSignupOTPVerificationState createState() => _PhoneSignupOTPVerificationState();
}

class _PhoneSignupOTPVerificationState extends State<PhoneSignupOTPVerification> {
  final TextEditingController otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  int _countdown = 60;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    otpController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _canResend = false;
    _countdown = 60;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_countdown > 0) {
            _countdown--;
          } else {
            _canResend = true;
            _timer?.cancel();
          }
        });
      }
    });
  }

  Future<void> _verifyOTP() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        bool success = await authProvider.verifyPhoneLoginOTP(
          widget.phone,
          otpController.text.trim(),
        );

        if (success) {
          // For signup, user always needs to create profile
          Navigator.pushNamedAndRemoveUntil(context, '/create-profile', (route) => false);
        } else {
          if (authProvider.errorMessage != null) {
            CustomToast.showToastDangerBottom(context, authProvider.errorMessage!);
          }
        }
      } catch (e) {
        CustomToast.showToastDangerBottom(context, e.toString());
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _resendOTP() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool success = await authProvider.resendPhoneOTP(widget.phone);
      
      if (success) {
        CustomToast.showToastSuccessBottom(context, 'Verification code sent!');
        _startCountdown();
      } else {
        CustomToast.showToastDangerBottom(context, 'Failed to resend code');
      }
    } catch (e) {
      CustomToast.showToastDangerBottom(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Verify Phone",
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
                SizedBox(height: 20),
                Icon(
                  Icons.phone_android,
                  size: 64,
                  color: AppColors.primaryRed,
                ),
                SizedBox(height: 24),
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
                SizedBox(height: 12),
                Text(
                  'We\'ve sent a 6-digit verification code to:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  widget.phone,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                CustomInputField(
                  icon: Icons.lock_outline,
                  placeholder: 'Enter 6-digit code',
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                SizedBox(height: 24),
                ButtonGradientMain(
                  label: isLoading ? 'Verifying...' : 'Verify & Continue',
                  onPressed: isLoading || otpController.text.length < 4 
                      ? () {} 
                      : _verifyOTP,
                  textColor: Colors.white,
                  gradientColors: !isLoading && otpController.text.length >= 4
                      ? [AppColors.primaryBlack, AppColors.primaryRed]
                      : [
                          AppColors.primaryRed.withOpacity(0.5),
                          AppColors.primaryBlack.withOpacity(0.5)
                        ],
                ),
                SizedBox(height: 24),
                if (!_canResend)
                  Text(
                    'Resend code in $_countdown seconds',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontFamily: 'Poppins',
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  )
                else
                  TextButton(
                    onPressed: _resendOTP,
                    child: Text(
                      'Resend Verification Code',
                      style: TextStyle(
                        color: AppColors.primaryRed,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Change Phone Number',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontFamily: 'Poppins',
                      fontSize: 14,
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