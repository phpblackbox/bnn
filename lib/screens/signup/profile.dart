import 'package:bnn/providers/auth_provider.dart';
import 'package:bnn/utils/colors.dart';
import 'package:bnn/widgets/buttons/button-gradient-main.dart';
import 'package:bnn/widgets/inputs/custom-input-field.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './age.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController biocontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  bool get isButtonEnabled {
    return firstnameController.text.isNotEmpty &&
        lastnameController.text.isNotEmpty;
  }

  Future<void> _update() async {
    if (isButtonEnabled) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        final profile = {
          'firstName': firstnameController.text.trim(),
          'lastName': lastnameController.text.trim(),
          'bio': biocontroller.text.trim(),
        };

        await authProvider.setProfile(profile);
        
        Navigator.push(context, MaterialPageRoute(builder: (context) => Age()));
      } catch (error) {
        CustomToast.showToastWarningBottom(
            context, 'Error updating profile: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Profile",
            style: TextStyle(fontFamily: "Archivo"),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacementNamed(context, '/home');
              }
            },
          ),
        ),
        body: Padding(
          padding:
              const EdgeInsets.only(left: 32, top: 16, right: 32, bottom: 32),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Full name",
                  ),
                  SizedBox(height: 10),
                  Column(
                    children: [
                      CustomInputField(
                        placeholder: 'First name',
                        controller: firstnameController,
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                      SizedBox(height: 10),
                      CustomInputField(
                        placeholder: 'Last name',
                        controller: lastnameController,
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Text(
                    "Bio",
                  ),
                  SizedBox(height: 10),
                  TextField(
                    style: TextStyle(fontSize: 12.0, fontFamily: "Poppins"),
                    maxLines: 5,
                    controller: biocontroller,
                    decoration: InputDecoration(
                      hintText: "Create a short bio",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      filled: true,
                      fillColor: Color(0xFFEAEAEA),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                    ),
                  ),
                ],
              ),
              Spacer(),
              ButtonGradientMain(
                label: 'Continue',
                onPressed: _update,
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
