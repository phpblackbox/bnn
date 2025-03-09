import 'dart:io';

import 'package:bnn/widgets/sub/bottom-navigation.dart';
import 'package:bnn/screens/live/liveDash.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Live extends StatefulWidget {
  const Live({super.key});

  @override
  _LiveState createState() => _LiveState();
}

class _LiveState extends State<Live> {
  var currentTime;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        DateTime now = DateTime.now();
        if (currentTime == null ||
            now.difference(currentTime) > const Duration(seconds: 2)) {
          currentTime = now;
          CustomToast.showToastWarningTop(context, "Press agian to exit");
          return Future.value(false);
        } else {
          SystemNavigator.pop();
          exit(0);
          // Future.value(false);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/call4.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 30,
              left: 0,
              child: IconButton(
                icon: Icon(Icons.close, size: 20, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Positioned(
              top: 30,
              right: 12,
              child: Column(
                children: [
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: ImageIcon(
                          AssetImage('assets/images/icons/flip.png'),
                          color: Colors.white,
                          size: 27,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Flip',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: ImageIcon(
                          AssetImage('assets/images/icons/reminder.png'),
                          color: Colors.white,
                          size: 27,
                        ),
                      ),
                      Text(
                        'Reminder',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: ImageIcon(
                          AssetImage('assets/images/icons/flash.png'),
                          color: Colors.white,
                          size: 27,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Flash',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: ImageIcon(
                          AssetImage('assets/images/icons/analytics.png'),
                          color: Colors.white,
                          size: 27,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Analytics',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            Positioned(
              top: 30,
              left: 40,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    // width: 220,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image(
                          image: AssetImage("assets/images/live/p1.png"),
                          width: 50,
                          height: 45,
                        ),
                        SizedBox(width: 10),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'poetry on purpose',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w800,
                                height: 1.13,
                                letterSpacing: -0.11,
                              ),
                            ),
                            Text(
                              'Lorem ipsum dolor sit amet, \nconsectetur adipiscing elit...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontFamily: 'Source Sans Pro',
                                fontWeight: FontWeight.w400,
                                height: 1.40,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    // width: 220,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image(
                          image: AssetImage("assets/images/addstory_btn.png"),
                          width: 20,
                          height: 18,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Add topic',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w800,
                            height: 1.42,
                            letterSpacing: -0.11,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LiveDash()));
                },
                child: Image(
                  image: AssetImage("assets/images/live/air.png"),
                  width: 97,
                  height: 97,
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigation(currentIndex: 3),
      ),
    );
  }
}
