import 'package:flutter/material.dart';
import 'package:bnn/utils/colors.dart';
import 'package:bnn/widgets/buttons/button-gradient-main.dart';
import 'package:bnn/widgets/inputs/custom-input-field.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:provider/provider.dart';
import 'package:bnn/providers/auth_provider.dart';
import 'package:bnn/screens/login/password_reset_verification.dart';

class AccountRecovery extends StatefulWidget {
  const AccountRecovery({Key? key}) : super(key: key);

  @override
  _AccountRecoveryState createState() => _AccountRecoveryState();
}

class _AccountRecoveryState extends State<AccountRecovery> {
  final TextEditingController _emailController = TextEditingController();
  bool isLoading = false;
  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _validateInput() {
    setState(() {
      isButtonEnabled = _emailController.text.isNotEmpty &&
          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
              .hasMatch(_emailController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Account Recovery",
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
                'Reset Your Password',
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
                'Enter your email address to receive a verification code',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              CustomInputField(
                icon: Icons.email,
                placeholder: 'Email Address',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  setState(() {});
                },
              ),
              SizedBox(height: 20),
              ButtonGradientMain(
                label: 'Send Verification Code',
                onPressed: isLoading || !isButtonEnabled
                    ? () {}
                    : () async {
                        setState(() {
                          isLoading = true;
                        });
                        try {
                          final authProvider =
                              Provider.of<AuthProvider>(context, listen: false);
                          bool status = await authProvider
                              .resetPassword(_emailController.text);
                          if (status) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PasswordResetVerification(
                                  email: _emailController.text,
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          CustomToast.showToastDangerBottom(
                              context, e.toString());
                        } finally {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                textColor: Colors.white,
                gradientColors: !isLoading
                    ? [
                        AppColors.primaryBlack,
                        AppColors.primaryRed,
                      ]
                    : [
                        AppColors.primaryBlack.withOpacity(0.5),
                        AppColors.primaryRed.withOpacity(0.5),
                      ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
