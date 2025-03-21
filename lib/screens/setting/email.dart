import 'package:flutter/material.dart';

class Email extends StatefulWidget {
  const Email({super.key});

  @override
  _Email createState() => _Email();
}

class _Email extends State<Email> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isMessage = false;
  bool _isPromotions = false;

  final TextEditingController emailController = TextEditingController();

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
    return emailController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.only(top: 48, left: 16, right: 16),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back,
                      size: 20.0, color: Color(0xFF4D4C4A)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(width: 5),
                Text(
                  'Email',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF4D4C4A),
                    fontSize: 14,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFE9E9E9),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: TextField(
                            style: TextStyle(
                                fontSize: 12.0, fontFamily: "Poppins"),
                            controller: emailController,
                            onChanged: (value) {
                              setState(() {});
                            },
                            enabled: false,
                            decoration: InputDecoration(
                              hintText: "johnsmith@gmail.com",
                              suffixIcon: IconButton(
                                icon: Icon(
                                  Icons.check,
                                  color: Color(0xFFF30802),
                                  size: 18,
                                ),
                                onPressed: () {},
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 10.0),
                            ),
                          ),
                        ),
                        Text(
                          'Your email is verified',
                          style: TextStyle(
                            color: Color(0xFFF30802),
                            fontSize: 12,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 32),
                        Container(
                          width: double.infinity,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Color(0xFFE9E9E9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              'Send email Verification',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xB24D4C4A),
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 32),
                        Container(
                          padding: EdgeInsets.only(top: 12, bottom: 12),
                          decoration: BoxDecoration(
                            color: Color(0xFFE9E9E9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.only(
                                    left: 14, top: 6, right: 14, bottom: 4),
                                child: Row(
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'New messages',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Color(0xFF4D4C4A),
                                            fontSize: 12,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    SizedBox(
                                      width: 25,
                                      height: 15,
                                      child: Transform.scale(
                                        scale: 0.5,
                                        child: Switch(
                                          value: _isMessage,
                                          onChanged: (value) {
                                            setState(() {
                                              _isMessage = value;
                                            });
                                          },
                                          activeColor: Color(0xFF800000),
                                          inactiveThumbColor: Color(0xFF4D4C4A),
                                          inactiveTrackColor: Colors.grey[300],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.only(left: 8, right: 8),
                                child: Divider(),
                              ),
                              Container(
                                padding: const EdgeInsets.only(
                                    left: 14, top: 6, right: 14, bottom: 4),
                                child: Row(
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Promotions',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Color(0xFF4D4C4A),
                                            fontSize: 12,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Text(
                                          'I want to receive news, updates and offers from BNN',
                                          style: TextStyle(
                                            color: Color(0x7F4D4C4A),
                                            fontSize: 8,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 2,
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    SizedBox(
                                      width: 25,
                                      height: 15,
                                      child: Transform.scale(
                                        scale: 0.5,
                                        child: Switch(
                                          value: _isPromotions,
                                          onChanged: (value) {
                                            setState(() {
                                              _isPromotions = value;
                                            });
                                          },
                                          activeColor: Color(0xFF800000),
                                          inactiveThumbColor: Color(0xFF4D4C4A),
                                          inactiveTrackColor: Colors.grey[300],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Control the emails you want to get - all of them, just the important stuff or the bare minimum. You can always unsubscribe at the bottom of any email',
                          style: TextStyle(
                            color: Color(0x7F4D4C4A),
                            fontSize: 9,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Color(0xFFE9E9E9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                              child: Text(
                            'Unsubscribe from all',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF4D4C4A),
                              fontSize: 15,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                            ),
                          )),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
