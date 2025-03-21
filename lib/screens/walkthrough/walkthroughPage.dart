import 'package:bnn/utils/colors.dart';
import 'package:flutter/material.dart';
import '../signup/signup_dash.dart';

class WalkthroughPage extends StatefulWidget {
  const WalkthroughPage({super.key});

  @override
  _WalkthroughPageState createState() => _WalkthroughPageState();
}

class _WalkthroughPageState extends State<WalkthroughPage> {
  int currentIndex = 0;

  final List<String> images = [
    'assets/images/walkthrough1.png',
    'assets/images/walkthrough2.png',
    'assets/images/walkthrough3.png',
  ];

  final List<String> titles = [
    'Connecting People',
    'Sharing Moments',
    'Privacy and Security',
  ];

  final List<IconData> icons = [
    Icons.message_rounded,
    Icons.telegram_outlined,
    Icons.privacy_tip,
  ];

  final List<String> texts = [
    'Join a global community and stay connected with friends, family, and like-minded individuals.',
    'Capture and share your favorite moments with the world.',
    'We’re committed to safeguarding your personal data and ensuring that your experience is safe and secure.',
  ];

  void _nextPage() {
    setState(() {
      if (currentIndex < images.length - 1) {
        currentIndex++;
      } else {
        currentIndex = 0;
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SignUpDash()));
      }
    });
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(images.length, (index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4.0),
          height: 8.0,
          width: 8.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: currentIndex == index
                ? Color(0xFFF30802)
                : AppColors.primaryBlack,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Column(
          children: [
            SizedBox(height: 30),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              child: SizedBox(
                height: 200,
                child: Center(
                  child: Image.asset(
                    images[currentIndex],
                    key: ValueKey<int>(currentIndex),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF101013),
                      Color(0xFF2C0000),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      child: Text(
                        titles[currentIndex],
                        key: ValueKey<int>(currentIndex),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Archivo',
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                        top: 16.0,
                        left: 10.0,
                        right: 10.0,
                        bottom: 8.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 20),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 600),
                            child: Icon(icons[currentIndex],
                                key: ValueKey<int>(currentIndex),
                                size: 20,
                                color: Colors.white),
                          ),
                          const SizedBox(width: 30),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 600),
                              child: Text(
                                texts[currentIndex],
                                key: ValueKey<int>(currentIndex),
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: "Nunito",
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildProgressIndicator(),
          ],
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: _nextPage,
            child: Image.asset(
              'assets/images/walkthrough_btn.png',
              key: ValueKey<int>(currentIndex),
              width: 150,
              height: 150.0,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ]),
    );
  }
}
