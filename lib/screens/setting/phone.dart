import 'package:flutter/material.dart';

class PhoneNumber extends StatefulWidget {
  const PhoneNumber({super.key});

  @override
  _PhoneNumber createState() => _PhoneNumber();
}

class _PhoneNumber extends State<PhoneNumber>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController phonenumberController = TextEditingController();

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
    return phonenumberController.text.isNotEmpty;
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
                  'Phone Number',
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
                          'PHONE NUMBER',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        SizedBox(height: 6),
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFE9E9E9),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: TextField(
                            style: TextStyle(
                                fontSize: 12.0, fontFamily: "Poppins"),
                            controller: phonenumberController,
                            onChanged: (value) {
                              setState(() {});
                            },
                            enabled: false,
                            decoration: InputDecoration(
                              hintText: "12345678901",
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
                        SizedBox(height: 6),
                        Text(
                          'verified phone number',
                          style: TextStyle(
                            color: Color(0xB54D4C4A),
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
                              'Update my phone number',
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
