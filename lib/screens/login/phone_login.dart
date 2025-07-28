import 'package:bnn/utils/colors.dart';
import 'package:bnn/widgets/buttons/button-gradient-main.dart';
import 'package:bnn/widgets/inputs/custom-input-field.dart';
import 'package:bnn/widgets/sub/splash-logo.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:country_flags/country_flags.dart';
import 'package:provider/provider.dart';
import 'package:bnn/providers/auth_provider.dart';
import 'phone_login_otp_verification.dart';

class PhoneLogin extends StatefulWidget {
  const PhoneLogin({super.key});

  @override
  _PhoneLoginState createState() => _PhoneLoginState();
}

class _PhoneLoginState extends State<PhoneLogin> {
  final TextEditingController _phoneController = TextEditingController();
  String _selectedCountryCode = 'US';
  String _selectedCountryPhoneCode = '1';
  bool isLoading = false;
  String _errorMessage = '';

  bool get isButtonEnabled {
    return _phoneController.text.isNotEmpty;
  }

  String get fullPhoneNumber {
    if (_phoneController.text.isNotEmpty) {
      String cleanPhone =
          _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
      return '+$_selectedCountryPhoneCode$cleanPhone';
    }
    return '';
  }

  Future<void> _handlePhoneLogin() async {
    if (!isButtonEnabled) return;

    setState(() {
      isLoading = true;
      _errorMessage = '';
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.loginWithPhone(fullPhoneNumber);

      if (!mounted) return; // <-- Add this check

      if (success) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhoneLoginOTPVerification(
              phone: fullPhoneNumber,
            ),
          ),
        );
      } else {
        setState(() {
          _errorMessage =
              authProvider.errorMessage ?? 'Failed to send verification code';
        });
        if (_errorMessage.isNotEmpty) {
          CustomToast.showToastDangerBottom(context, _errorMessage);
        }
      }
    } catch (e) {
      if (!mounted) return; // <-- Add this check
      setState(() {
        _errorMessage = e.toString();
      });
      CustomToast.showToastDangerBottom(context, _errorMessage);
    } finally {
      // ignore: control_flow_in_finally
      if (!mounted) return; // <-- Add this check
      setState(() {
        isLoading = false;
      });
    }
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
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Phone Login',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                      fontFamily: 'Archivo',
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Enter your phone number to receive a verification code',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                      fontFamily: 'Poppins',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(100, 50),
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 8.0),
                          backgroundColor: Color(0xFFF5F5F5),
                          elevation: 0,
                        ),
                        onPressed: () {
                          showCountryPicker(
                            context: context,
                            favorite: <String>['US'],
                            showPhoneCode: true,
                            onSelect: (Country country) {
                              setState(() {
                                _selectedCountryCode = country.countryCode;
                                _selectedCountryPhoneCode = country.phoneCode;
                                _errorMessage = '';
                              });
                            },
                            moveAlongWithKeyboard: false,
                            countryListTheme: CountryListThemeData(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(40.0),
                                topRight: Radius.circular(40.0),
                              ),
                              inputDecoration: InputDecoration(
                                labelText: 'Search',
                                hintText: 'Start typing to search',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFFCCCCCC),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20.0,
                              height: 20.0,
                              child: CountryFlag.fromCountryCode(
                                  _selectedCountryCode),
                            ),
                            Text(
                              '  +$_selectedCountryPhoneCode',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(Icons.arrow_drop_down, color: Colors.black),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.0),
                      Expanded(
                        child: CustomInputField(
                          icon: Icons.phone,
                          placeholder: 'Phone Number',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          onChanged: (value) {
                            setState(() {
                              _errorMessage = '';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "By providing your phone number, you agree to receive security verification codes to access your account.",
                        style:
                            TextStyle(fontSize: 12, color: Color(0xFF666666)),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Message and data rates may apply.",
                        style:
                            TextStyle(fontSize: 12, color: Color(0xFF666666)),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Message frequency varies depending on your activity.",
                        style:
                            TextStyle(fontSize: 12, color: Color(0xFF666666)),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Reply HELP for help, STOP to cancel.",
                        style:
                            TextStyle(fontSize: 12, color: Color(0xFF666666)),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  if (_errorMessage.isNotEmpty)
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFF5F5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Color(0xFFFFCCCC)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              Spacer(),
              ButtonGradientMain(
                label: isLoading ? 'Sending Code...' : 'Send Verification Code',
                onPressed: isLoading ? () {} : _handlePhoneLogin,
                textColor: Colors.white,
                gradientColors: isButtonEnabled && !isLoading
                    ? [AppColors.primaryBlack, AppColors.primaryRed]
                    : [
                        AppColors.primaryRed.withOpacity(0.5),
                        AppColors.primaryBlack.withOpacity(0.5)
                      ],
              ),
              SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    'Back to Login Options',
                    style: TextStyle(
                      color: AppColors.primaryRed,
                      fontFamily: 'Poppins',
                      fontSize: 14,
                    ),
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
