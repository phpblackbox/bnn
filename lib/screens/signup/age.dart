import 'package:bnn/providers/auth_provider.dart';
import 'package:bnn/screens/signup/interests.dart';
import 'package:bnn/utils/colors.dart';
import 'package:bnn/widgets/buttons/button-gradient-main.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:provider/provider.dart';

class Age extends StatefulWidget {
  const Age({super.key});

  @override
  State<Age> createState() => _AgeState();
}

class _AgeState extends State<Age> with SingleTickerProviderStateMixin {
  var age = 25;

  final List<String> ageList =
      List.generate(100, (index) => (index + 1).toString());

  @override
  void initState() {
    super.initState();
  }

  bool get isButtonEnabled {
    return true;
  }

  Future<void> _update() async {
    if (isButtonEnabled) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        final profile = {"age": age};

        await authProvider.setProfile(profile);

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Interests()));
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
            "My age is",
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
            child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 150.0,
                    child: TextButton(
                      child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Your age',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                      onPressed: () => showMaterialNumberPicker(
                        context: context,
                        title: 'Select Your Age',
                        maxNumber: 100,
                        minNumber: 15,
                        selectedNumber: age,
                        onChanged: (value) => setState(() => age = value),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      age.toString(),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
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
        )),
      ),
    );
  }
}
