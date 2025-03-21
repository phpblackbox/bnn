import 'package:bnn/providers/auth_provider.dart';
import 'package:bnn/utils/colors.dart';
import 'package:bnn/widgets/buttons/button-gradient-main.dart';
import 'package:bnn/widgets/sub/splash-logo.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './profile.dart';

class Gender extends StatefulWidget {
  const Gender({super.key});

  @override
  _Gender createState() => _Gender();
}

class _Gender extends State<Gender> with SingleTickerProviderStateMixin {
  final TextEditingController usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  bool get isButtonEnabled {
    return selectedGender.isNotEmpty;
  }

  String selectedGender = '';

  void selectGender(String gender) {
    setState(() {
      selectedGender = gender;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return SafeArea(
      child: Scaffold(
        body: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SplashLogo(),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'I am a ',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontFamily: "Archivo",
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => selectGender('man'),
                        child: Image.asset(
                          selectedGender == 'man'
                              ? 'assets/images/gender_man_select.png'
                              : 'assets/images/gender_man.png',
                          width: 150,
                          height: 150,
                        ),
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => selectGender('woman'),
                        child: Image.asset(
                          selectedGender == 'woman'
                              ? 'assets/images/gender_woman_select.png'
                              : 'assets/images/gender_woman.png',
                          width: 150,
                          height: 150,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Spacer(),
              ButtonGradientMain(
                label: 'Continue',
                onPressed: () async {
                  try {
                    if (isButtonEnabled) {
                      int gender = 0;
                      switch (selectedGender) {
                        case "no_gender":
                          gender = 0;
                          break;
                        case "man":
                          gender = 1;
                          break;
                        case "woman":
                          gender = 2;
                          break;
                      }

                      final profile = {'gender': gender};

                      await authProvider.setProfile(profile);

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Profile()),
                      );
                    }
                  } catch (error) {
                    CustomToast.showToastWarningBottom(
                        context, error.toString());
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
