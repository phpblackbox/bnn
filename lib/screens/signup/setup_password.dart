import 'package:bnn/utils/colors.dart';
import 'package:bnn/widgets/buttons/button-gradient-main.dart';
import 'package:bnn/widgets/inputs/custom-input-field.dart';
import 'package:flutter/material.dart';
import './gender.dart';

class SetupPassowrd extends StatefulWidget {
  const SetupPassowrd({super.key});

  @override
  _SetupPassowrd createState() => _SetupPassowrd();
}

class _SetupPassowrd extends State<SetupPassowrd>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController passwordController = TextEditingController();

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
    return passwordController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Setup Password",
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
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        children: [
                          CustomInputField(
                            placeholder: 'Type your password',
                            controller: passwordController,
                            isPassword: true,
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Spacer(),
              ButtonGradientMain(
                label: 'Continue',
                onPressed: () {
                  if (isButtonEnabled) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Gender()));
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
