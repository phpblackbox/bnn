import 'package:bnn/utils/colors.dart';
import 'package:bnn/widgets/buttons/button-gradient-main.dart';
import 'package:bnn/widgets/inputs/custom-input-field.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:country_flags/country_flags.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:bnn/providers/auth_provider.dart';
import 'phone_signup_otp_verification.dart';

class PhoneSignUp extends StatefulWidget {
  const PhoneSignUp({super.key});

  @override
  _PhoneSignUpState createState() => _PhoneSignUpState();
}

class _PhoneSignUpState extends State<PhoneSignUp> {
  final TextEditingController _phoneController = TextEditingController();
  String? _selectedCountryCode;
  String? _selectedCountryPhoneCode;
  bool isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Set default country to US
    _selectedCountryCode = 'US';
    _selectedCountryPhoneCode = '1';
  }

  bool get isButtonEnabled {
    return _phoneController.text.isNotEmpty && _selectedCountryCode != null;
  }

  String get fullPhoneNumber {
    if (_selectedCountryPhoneCode != null && _phoneController.text.isNotEmpty) {
      String cleanPhone = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
      return '+${_selectedCountryPhoneCode!}$cleanPhone';
    }
    return '';
  }

  Future<void> _handlePhoneSignup() async {
    if (!isButtonEnabled) return;

    setState(() {
      isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.signUpWithPhone(fullPhoneNumber);

      if (success) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PhoneSignupOTPVerification(
                phone: fullPhoneNumber,
              ),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = authProvider.errorMessage ?? 'Failed to send verification code';
        });
        if (mounted && _errorMessage != null) {
          CustomToast.showToastDangerBottom(context, _errorMessage!);
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      if (mounted) {
        CustomToast.showToastDangerBottom(context, _errorMessage!);
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _handleSkip() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Phone Sign Up",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter your phone number',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Archivo',
                ),
              ),
              SizedBox(height: 8),
              Text(
                'We\'ll send you a verification code to get started',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(100, 50),
                      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      backgroundColor: Colors.grey[100],
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
                            _errorMessage = null;
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
                                color: const Color(0xFF8C98A8).withOpacity(0.2),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_selectedCountryCode != null)
                          SizedBox(
                            width: 20.0,
                            height: 20.0,
                            child: CountryFlag.fromCountryCode(_selectedCountryCode!),
                          ),
                        if (_selectedCountryPhoneCode != null)
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
                          _errorMessage = null;
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
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Message and data rates may apply.",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Message frequency varies depending on your activity.",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Reply HELP for help, STOP to cancel.",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              SizedBox(height: 16),
              if (_errorMessage != null)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[600], size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              Spacer(),
              
              Row(
                children: [
                  Expanded(
                    child: ButtonGradientMain(
                      label: 'SKIP',
                      onPressed: _handleSkip,
                      textColor: Colors.grey[700]!,
                      gradientColors: [Colors.white, Colors.white],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ButtonGradientMain(
                      label: isLoading ? 'Sending Code...' : 'CONTINUE',
                      onPressed: isLoading ? () {} : _handlePhoneSignup,
                      textColor: Colors.white,
                      gradientColors: isButtonEnabled && !isLoading
                          ? [AppColors.primaryBlack, AppColors.primaryRed]
                          : [
                              AppColors.primaryRed.withOpacity(0.5),
                              AppColors.primaryBlack.withOpacity(0.5)
                            ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}