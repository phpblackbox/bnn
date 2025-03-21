import 'package:flutter/material.dart';

class MyVisibility extends StatefulWidget {
  const MyVisibility({super.key});

  @override
  State<MyVisibility> createState() => _MyVisibilityState();
}

class _MyVisibilityState extends State<MyVisibility> {
  bool _isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'My Visibility',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF4D4C4A),
              fontSize: 18,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
              height: 0.85,
              letterSpacing: -0.11,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 20.0, color: Color(0xFF4D4C4A)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(
                  left: 16, top: 12, right: 16, bottom: 12),
              decoration: BoxDecoration(
                color: Color(0xFFE9E9E9),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Active Status',
                          style: TextStyle(
                            color: Color(0xFF4D4C4A),
                            fontSize: 16,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                            height: 1.06,
                            letterSpacing: -0.11,
                          ),
                        ),
                        Text(
                          _isSwitched
                              ? 'Your Account will be seen oneline'
                              : 'Your Account will be seen offline',
                          style: TextStyle(
                            color: Color(0xFF4D4C4A),
                            fontSize: 10,
                            fontFamily: 'Nunito',
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
                          value: _isSwitched,
                          onChanged: (value) {
                            setState(() {
                              _isSwitched = value;
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
            ),
          ],
        ),
      ),
    );
  }
}
