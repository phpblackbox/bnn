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
import 'phone_otp_verification.dart';

class PhoneSignUp extends StatefulWidget {
  const PhoneSignUp({super.key});

  @override
  _PhoneSignUp createState() => _PhoneSignUp();
}

class _PhoneSignUp extends State<PhoneSignUp>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;

  final TextEditingController _phoneController = TextEditingController();
  String? _selectedCountryCode;
  String? _selectedCountryPhoneCode;
  bool isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }

  bool get isButtonEnabled {
    if (_selectedCountryCode != null) {
      return _phoneController.text.isNotEmpty &&
          _selectedCountryCode!.isNotEmpty;
    } else {
      return false;
    }
  }

  String get fullPhoneNumber {
    if (_selectedCountryPhoneCode != null && _phoneController.text.isNotEmpty) {
      String cleanPhone =
          _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
      return '+${_selectedCountryPhoneCode!}$cleanPhone';
    }
    return '';
  }

  Future<void> _handlePhoneVerification() async {
    if (!isButtonEnabled) return;

    setState(() {
      isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.verifyPhone(fullPhoneNumber);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhoneOTPVerification(
              phone: fullPhoneNumber,
            ),
          ),
        );
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
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(100, 40),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                          searchTextStyle: TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_selectedCountryCode != null)
                          SizedBox(
                            width: 18.0,
                            height: 18.0,
                            child: CountryFlag.fromCountryCode(
                                _selectedCountryCode!),
                          ),
                        if (_selectedCountryPhoneCode != null)
                          Text('  +$_selectedCountryPhoneCode '),
                        SizedBox(width: 8.0),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: CustomInputField(
                      icon: Icons.phone,
                      placeholder: 'Phone Number',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                  "When you tap Continue, BNN will send a verification code. Message and data rates may apply. The verified phone number can be used to login. Learn what happens when your number changes"),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              Spacer(),
              ButtonGradientMain(
                label: isLoading ? 'Sending Code...' : 'Continue',
                onPressed: isLoading ? () {} : () => _handlePhoneVerification(),
                textColor: Colors.white,
                gradientColors: isButtonEnabled && !isLoading
                    ? [AppColors.primaryBlack, AppColors.primaryRed]
                    : [
                        AppColors.primaryRed.withOpacity(0.5),
                        AppColors.primaryBlack.withOpacity(0.5)
                      ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
