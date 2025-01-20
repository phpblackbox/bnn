import 'package:flutter/material.dart';
import 'ButtonGradientMain.dart';
import './addphoto.dart';

class TermsOfService extends StatefulWidget {
  const TermsOfService({super.key});

  @override
  State<TermsOfService> createState() => _TermsOfServiceState();
}

class _TermsOfServiceState extends State<TermsOfService>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  bool _accepted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Start the animation
    _controller.forward();
  }

  bool get isButtonEnabled {
    return _accepted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Terms Of Service",
            style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 14,
                fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0), // Padding for the entire column
        child: Stack(
          children: [
            Column(
              children: [
                Text(
                  "BNN TERMS AND CONDITIONS OF SERVICE",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Poppins"),
                ),
                SizedBox(height: 20),
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    child: Text(
                      "Acknowledgment\n\n"
                      "These are the Terms and Conditions governing the use of this Service and the agreement that operates between You and the Company. These Terms and Conditions set out the rights and obligations of all users regarding the use of the Service.\n\n"
                      "Your access to and use of the Service is conditioned on Your acceptance of and compliance with these Terms and Conditions. These Terms and Conditions apply to all visitors, users and others who access or use the Service.\n\n"
                      "By accessing or using the Service You agree to be bound by these Terms and Conditions. If You disagree with any part of these Terms and Conditions then You may not access the Service.\n\n"
                      "You represent that you are over the age of 18. The Company does not permit those under 18 to use the Service.\n\n"
                      "Your access to and use of the Service is also conditioned on Your acceptance of and compliance with the Privacy Policy of the Company. Our Privacy Policy describes Our policies and procedures on the collection, use and disclosure of Your personal information when You use the Application or the Website and tells You about Your privacy rights and how the law protects You. Please read Our Privacy Policy carefully before using Our Service.",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Spacer(),
                Row(
                  children: [
                    Checkbox(
                      value: _accepted,
                      onChanged: (value) {
                        setState(() {
                          _accepted = value!;
                        });
                      },
                      activeColor: Colors.black,
                    ),
                    Text(
                      'I accept the terms and conditions',
                      style: TextStyle(
                          fontSize: 10,
                          fontFamily: "Nunito",
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                ButtonGradientMain(
                  label: 'Continue',
                  onPressed: () {
                    if (_accepted) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Photo()));
                    }
                  },
                  textColor: Colors.white,
                  gradientColors: isButtonEnabled
                      ? [
                          Color(0xFF000000),
                          Color(0xFF820200)
                        ] // Active gradient
                      : [
                          Color(0xFF820200).withOpacity(0.5),
                          Color(0xFF000000).withOpacity(0.5)
                        ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
