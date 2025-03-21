import 'package:bnn/screens/home/home.dart';
import 'package:bnn/screens/setting/applyBnn.dart';
import 'package:flutter/material.dart';

class BnnPro extends StatefulWidget {
  const BnnPro({super.key});

  @override
  State<BnnPro> createState() => BnnProState();
}

class BnnProState extends State<BnnPro> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Row(
              children: [
                Spacer(),
                Container(
                  padding: EdgeInsets.only(top: 48, right: 16),
                  child: IconButton(
                    icon: Icon(Icons.close),
                    iconSize: 28,
                    color: Colors.black,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
            Image(
                image: AssetImage("assets/images/bnn_logo.png"),
                width: 80,
                height: 80),
            Image(
                image: AssetImage("assets/images/settings/1.png"),
                fit: BoxFit.fill,
                width: 100,
                height: 60),
            SizedBox(height: 4),
            Text(
              'Citizenship Badge',
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
            SizedBox(height: 4),
            Text(
              'Obtain BNN Citizenship and be able go On Air, Post, and Interact',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF4D4C4A),
                fontSize: 12,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: Color(0xFF800000),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 4),
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 4),
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Column(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 8, right: 8),
                  padding: EdgeInsets.all(4),
                  height: 64,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 3, color: Color(0xFF898989)),
                      borderRadius: BorderRadius.circular(27),
                    ),
                  ),
                  child: Container(
                    decoration: ShapeDecoration(
                      color: Color(0xFF808080),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(21),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 12),
                        Text(
                          'Standard',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                            height: 2.80,
                          ),
                        ),
                        Spacer(),
                        Text(
                          'Free',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w500,
                            height: 3.73,
                          ),
                        ),
                        SizedBox(width: 12),
                      ],
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: SizedBox(
                        height: 200,
                        width: double.maxFinite,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ImageIcon(
                              AssetImage('assets/images/icons/verified.png'),
                              color: Color(0xFF00A5FF),
                              size: 45,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Subscription Confirmed',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF4D4C4A),
                                fontSize: 20,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.50,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'You are now a citizen on BNN ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF4D4C4A),
                                fontSize: 12,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                letterSpacing: -0.50,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Order id:  0854786',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF4D4C4A),
                                fontSize: 12,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                letterSpacing: -0.50,
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Home()));
                          },
                          child: Container(
                            width: 250,
                            height: 56,
                            decoration: ShapeDecoration(
                              color: Color(0xFFF30802).withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Back to home',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFF30802),
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        )
                      ],
                    );
                  },
                );
              },
              child: Container(
                height: 52,
                margin: EdgeInsets.only(left: 16, right: 16),
                padding: EdgeInsets.all(4),
                decoration: ShapeDecoration(
                  color: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(21),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 12),
                    Text(
                      'Boss',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        height: 2.80,
                      ),
                    ),
                    SizedBox(width: 8),
                    ImageIcon(
                      AssetImage('assets/images/icons/verified.png'),
                      color: Color(0xFF00A5FF),
                      size: 16,
                    ),
                    Spacer(),
                    Text(
                      "\$7/Mon \$56/Year ",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w500,
                        height: 3.73,
                      ),
                    ),
                    SizedBox(width: 12),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ApplyBNN()));
              },
              child: Container(
                height: 52,
                margin: EdgeInsets.only(left: 16, right: 16),
                padding: EdgeInsets.all(4),
                decoration: ShapeDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black, Color(0xFF800000)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(21),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 12),
                    Text(
                      'Elite',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        height: 2.80,
                      ),
                    ),
                    SizedBox(width: 8),
                    // ImageIcon(
                    //   AssetImage('assets/images/icons/verified.png'),
                    //   color: Color(0xFFF30802),
                    //   size: 16,
                    // ),
                    Spacer(),
                    Text(
                      "Apply",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w500,
                        height: 3.73,
                      ),
                    ),
                    SizedBox(width: 12),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Go back',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black.withOpacity(0.6100000143051147),
                fontSize: 13,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(width: 8),
                Text(
                  'Restore',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.6100000143051147),
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  width: 1,
                  height: 14,
                  decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                ),
                Text(
                  'Privacy Policy',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.6100000143051147),
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  width: 1,
                  height: 14,
                  decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                ),
                Text(
                  'Terms Of Service',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.6100000143051147),
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 8),
              ],
            )
          ],
        ),
      ),
    );
  }
}
