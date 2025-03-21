import 'package:bnn/utils/colors.dart';
import 'package:bnn/widgets/buttons/button-gradient-main.dart';
import 'package:bnn/widgets/inputs/custom-input-field.dart';
import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:country_flags/country_flags.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PhoneSignUp extends StatefulWidget {
  const PhoneSignUp({super.key});

  @override
  _PhoneSignUp createState() => _PhoneSignUp();
}

class _PhoneSignUp extends State<PhoneSignUp>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _phoneController = TextEditingController();
  String? _selectedCountryCode;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
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

    _controller.forward();
  }

  bool get isButtonEnabled {
    if (_selectedCountryCode != null) {
      return _phoneController.text.isNotEmpty &&
          _selectedCountryCode!.isNotEmpty;
    } else {
      return false;
    }
  }

  String selectedPhoneSignUp = '';

  void selectPhoneSignUp(String PhoneSignUp) {
    setState(() {
      selectedPhoneSignUp = PhoneSignUp;
    });
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
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(100, 40),
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                        ),
                        onPressed: () {
                          showCountryPicker(
                            context: context,
                            favorite: <String>['US'],
                            showPhoneCode: true,
                            onSelect: (Country country) {
                              setState(() {
                                _selectedCountryCode = country.countryCode;
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
                                    color: const Color(0xFF8C98A8)
                                        .withOpacity(0.2),
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
                                width: 24.0,
                                height: 24.0,
                                child: CountryFlag.fromCountryCode(
                                    _selectedCountryCode!),
                              ),
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
                  Spacer(),
                  ButtonGradientMain(
                    label: 'Continue',
                    onPressed: () async {
                      if (isButtonEnabled) {
                        // final AuthResponse res = await supabase.auth.verifyOTP(
                        //   type: OtpType.sms,
                        //   token: '111111',
                        //   phone: '+12149374719',
                        // );
                        // final Session? session = res.session;
                        // final User? user = res.user;
                        await supabase.auth.signInWithOtp(
                          phone: '+12149374719',
                        );
                        // Navigator.push(context,
                        //     MaterialPageRoute(builder: (context) => OTP()));
                      }
                    },
                    textColor: Colors.white,
                    gradientColors: isButtonEnabled
                        ? [
                            AppColors.primaryBlack,
                            AppColors.primaryRed
                          ] // Active gradient
                        : [
                            AppColors.primaryRed.withOpacity(0.5),
                            AppColors.primaryBlack.withOpacity(0.5)
                          ],
                  ),
                  // Submit Button
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
