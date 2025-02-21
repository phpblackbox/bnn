import 'package:bnn/screens/signup/otp.dart';
import 'package:bnn/utils/colors.dart';
import 'package:bnn/widgets/buttons/button-gradient-main.dart';
import 'package:bnn/widgets/inputs/custom-input-field.dart';
import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:country_flags/country_flags.dart';

class PhoneLogin extends StatefulWidget {
  const PhoneLogin({super.key});

  @override
  _PhoneLogin createState() => _PhoneLogin();
}

class _PhoneLogin extends State<PhoneLogin>
    with SingleTickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  String? _selectedCountryCode;

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

  // This variable keeps track of the currently selected PhoneLogin
  String selectedPhoneLogin = '';

  // Method to select PhoneLogin and update the UI
  void selectPhoneLogin(String PhoneLogin) {
    setState(() {
      selectedPhoneLogin = PhoneLogin; // Update the selected PhoneLogin
    });
  }

  @override
  Widget build(BuildContext context) {
    // Start a timer to navigate to the next page after 3 seconds

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Phone Log in",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Back arrow icon
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // You can adjust alignment as needed
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize:
                        Size(100, 40), // Set a minimum width and height
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical:
                            8.0), // Adjust horizontal and vertical padding
                  ),
                  onPressed: () {
                    showCountryPicker(
                      context: context,
                      favorite: <String>['US'],
                      showPhoneCode: true,
                      onSelect: (Country country) {
                        setState(() {
                          _selectedCountryCode = country
                              .countryCode; // Store the selected country code
                        });
                        print(
                            'Selected country: ${country.displayName} ___ ${country.countryCode}');
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
                          width: 24.0, // Set your desired width
                          height: 24.0, // Set your desired height
                          child: CountryFlag.fromCountryCode(
                              _selectedCountryCode!),
                        ),
                      // Optionally, add some text to the button
                      SizedBox(width: 8.0), // Spacer betwon text
                    ],
                  ),
                ),
                SizedBox(width: 8.0),
                Expanded(
                  // Use Expanded to allow the input field to take up remaining space
                  child: CustomInputField(
                    icon: Icons.phone,
                    placeholder: 'Phone Number',
                    controller: _phoneController,
                    onChanged: (value) {
                      setState(() {}); // Update state on phone field change
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
              onPressed: () {
                if (isButtonEnabled) {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => OTP()));
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
    );
  }
}
