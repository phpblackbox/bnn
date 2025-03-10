import 'package:bnn/providers/auth_provider.dart';
import 'package:bnn/screens/signup/gender.dart';
import 'package:bnn/utils/colors.dart';
import 'package:bnn/widgets/buttons/button-gradient-main.dart';
import 'package:bnn/widgets/inputs/custom-input-field.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateUserName extends StatefulWidget {
  const CreateUserName({super.key});

  @override
  _CreateUserNameState createState() => _CreateUserNameState();
}

class _CreateUserNameState extends State<CreateUserName> {
  final supabase = Supabase.instance.client;

  final TextEditingController usernameController = TextEditingController();

  bool get isButtonEnabled {
    return usernameController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Create Username",
            style: TextStyle(fontFamily: "Archivo"),
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
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    children: [
                      CustomInputField(
                        placeholder: 'Create your username',
                        controller: usernameController,
                        onChanged: (value) {
                          setState(() {});
                        },
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
                      final profile = {'username': usernameController.text};
                      await authProvider.createProfile();
                      await authProvider.setProfile(profile);

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Gender()),
                      );
                    }
                  } catch (error) {
                    print(error);
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
