import 'package:bnn/screens/signup/signup_dash.dart';
import 'package:bnn/utils/colors.dart';
import 'package:bnn/widgets/buttons/button-gradient-main.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class OTP extends StatefulWidget {
  const OTP({super.key});

  @override
  State<OTP> createState() => _OTPState();
}

class _OTPState extends State<OTP> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _otpController = TextEditingController();
  Timer? _timer;
  int _start = 59;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    startTimer();

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
    return _otpController.text.isNotEmpty;
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _timer?.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  void _sendAgain() {
    setState(() {
      _start = 59; // Reset timer
      startTimer(); // Restart timer
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel timer on dispose
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Enter OTP Code",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '00:${_start < 10 ? '0$_start' : _start}',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),

                        SizedBox(height: 10),

                        // Instruction Text
                        Text(
                          "Type the verification code \n we’ve sent you",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),

                        SizedBox(height: 10),

                        SizedBox(
                          width: 150, // Set a smaller width
                          child: TextField(
                            controller: _otpController,
                            maxLength: 4,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16), // Smaller font size
                            decoration: InputDecoration(
                              counterText: '',
                              border: OutlineInputBorder(),
                              hintText: 'Enter OTP',
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 8.0), // Adjust padding
                            ),
                          ),
                        ),

                        SizedBox(height: 10),

                        // Dial Pad
                        GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: 12,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return _buildDialButton(index);
                          },
                        ),

                        SizedBox(height: 20),

                        // Send Again Text
                        GestureDetector(
                          onTap: _sendAgain,
                          child: Text(
                            'Send Again',
                            style: TextStyle(
                                color: Color(0xFFF30802),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Poppins"),
                          ),
                        ),

                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
              Spacer(),
              ButtonGradientMain(
                label: 'Continue',
                onPressed: () {
                  if (isButtonEnabled) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SignUpDash()));
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialButton(int index) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        minimumSize: Size(24, 24), // Smaller minimum size
        padding: EdgeInsets.all(4.0), // Reduced padding
      ),
      onPressed: () {
        String currentText = _otpController.text;
        if (index < 9 && currentText.length < 4) {
          _otpController.text += (index + 1).toString();
        } else if (index == 11) {
          // _otpController.clear();
          _otpController.text =
              _otpController.text.substring(0, _otpController.text.length - 1);
        } else {
          // Handle adding zero
          if (currentText.length < 4) {
            _otpController.text += '0';
          }
        }
      },
      child: index == 11
          ? Icon(Icons.backspace, color: Colors.black)
          : index == 9
              ? null
              : Text(
                  '${index < 9 ? index + 1 : 0}',
                  style: TextStyle(color: Colors.black),
                ),
    );
  }
}
