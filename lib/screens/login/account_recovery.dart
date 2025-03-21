import 'package:bnn/screens/login/login_dash.dart';
import 'package:bnn/utils/colors.dart';
import 'package:bnn/widgets/buttons/button-gradient-main.dart';
import 'package:bnn/widgets/inputs/custom-input-field.dart';
import 'package:flutter/material.dart';

class AccountRecovery extends StatefulWidget {
  const AccountRecovery({super.key});

  @override
  State<AccountRecovery> createState() => _AccountRecoveryState();
}

class _AccountRecoveryState extends State<AccountRecovery>
    with SingleTickerProviderStateMixin {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController biocontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  bool get isButtonEnabled {
    return addressController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Account Recovery"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Container(
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    children: [
                      CustomInputField(
                        placeholder: 'Your email address',
                        controller: addressController,
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    "we’ll email you with a link that will instantly recover your account",
                    style: TextStyle(fontFamily: "Nunito", fontSize: 11),
                  ),
                ],
              ),
              Spacer(),
              ButtonGradientMain(
                label: 'Continue',
                onPressed: () {
                  if (isButtonEnabled) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginDash()));
                  }
                },
                textColor: Colors.white,
                gradientColors: isButtonEnabled
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
