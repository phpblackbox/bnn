import 'package:flutter/material.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  bool _isMessage = false;
  bool _isAppActivity = false;
  bool _isAppOffers = false;
  bool _isAppSounds = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Notifications',
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
              padding: const EdgeInsets.only(top: 6, bottom: 6),
              decoration: BoxDecoration(
                color: Color(0xFFE9E9E9), // Grey background color
                borderRadius: BorderRadius.circular(8.0), // Border radius
              ),
              child: Column(children: [
                Container(
                  padding: const EdgeInsets.only(
                      left: 14, top: 6, right: 14, bottom: 4),
                  child: Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Messages',
                            style: TextStyle(
                              color: Color(0xFF4D4C4A),
                              fontSize: 14,
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w700,
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
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Divider(),
                ),
                Container(
                  padding: const EdgeInsets.only(
                      left: 14, top: 6, right: 14, bottom: 4),
                  child: Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'In-app activity',
                            style: TextStyle(
                              color: Color(0xFF4D4C4A),
                              fontSize: 14,
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w700,
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
                            value: _isAppActivity,
                            onChanged: (value) {
                              setState(() {
                                _isAppActivity = value;
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
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Divider(),
                ),
                Container(
                  padding: const EdgeInsets.only(
                      left: 14, top: 6, right: 14, bottom: 4),
                  child: Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'App offers',
                            style: TextStyle(
                              color: Color(0xFF4D4C4A),
                              fontSize: 14,
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w700,
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
                            value: _isAppOffers,
                            onChanged: (value) {
                              setState(() {
                                _isAppOffers = value;
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
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Divider(),
                ),
                Container(
                  padding: const EdgeInsets.only(
                      left: 14, top: 6, right: 14, bottom: 4),
                  child: Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'in-app sounds',
                            style: TextStyle(
                              color: Color(0xFF4D4C4A),
                              fontSize: 14,
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w700,
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
                            value: _isAppSounds,
                            onChanged: (value) {
                              setState(() {
                                _isAppSounds = value;
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
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
