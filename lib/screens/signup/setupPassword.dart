import 'package:flutter/material.dart';
import './CustomInputField.dart';
import 'ButtonGradientMain.dart';
import './gender.dart';

class SetupPassowrd extends StatefulWidget {
  _SetupPassowrd createState() => _SetupPassowrd();
}

class _SetupPassowrd extends State<SetupPassowrd>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController passwordController = TextEditingController();

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

    // Start the animation
    _controller.forward();
  }

  bool get isButtonEnabled {
    return passwordController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    // Start a timer to navigate to the next page after 3 seconds

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Setup Password",
          style: TextStyle(fontFamily: "Archivo"),
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
                            setState(
                                () {}); // Update state on email field change
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
                  ? [Color(0xFF000000), Color(0xFF820200)] // Active gradient
                  : [
                      Color(0xFF820200).withOpacity(0.5),
                      Color(0xFF000000).withOpacity(0.5)
                    ],
            ),
          ],
        ),
      ),
    );
  }
}
