import 'package:bnn/screens/home/home.dart';
import 'package:bnn/utils/colors.dart';
import 'package:bnn/widgets/buttons/button-gradient-main.dart';
import 'package:flutter/material.dart';

class ApplyBNN extends StatefulWidget {
  const ApplyBNN({super.key});

  @override
  State<ApplyBNN> createState() => _ApplyBNNState();
}

class _ApplyBNNState extends State<ApplyBNN> {
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 16, left: 8, right: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apply for BNN Boss',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'In order to obtain BNN Boss, you must verify your work email address and send us a signed letter affirming your Identity',
              style: TextStyle(
                color: Colors.black.withOpacity(0.5),
                fontSize: 10,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                height: 1.50,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Work Email',
              style: TextStyle(
                color: Colors.black,
                fontSize: 10,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w300,
              ),
            ),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFE9E9E9),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: TextField(
                style: TextStyle(fontSize: 12.0, fontFamily: "Poppins"),
                controller: emailController,
                onChanged: (value) {
                  setState(() {});
                },
                enabled: false,
                decoration: InputDecoration(
                  hintText: "johndoe.com",
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.check,
                      color: Color(0xF4327AFF),
                      size: 18,
                    ),
                    onPressed: () {},
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                ),
              ),
            ),
            Text(
              'Your email is verified',
              style: TextStyle(
                color: Color(0xB54D4C4A),
                fontSize: 12,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(color: Color(0xFFE9E9E9)),
              child: Center(
                child: Text(
                  'Send email Verification',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF4D4C4A),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Attach letter here',
              style: TextStyle(
                color: Colors.black,
                fontSize: 10,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w300,
              ),
            ),
            Image(image: AssetImage("assets/images/settings/download.png")),
            SizedBox(height: 25),
            Center(
              child: SizedBox(
                width: 250,
                child: ButtonGradientMain(
                    label: "Send Application",
                    onPressed: () {
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
                                    AssetImage(
                                        'assets/images/icons/verified.png'),
                                    color: Color(0xFFF30802),
                                    size: 45,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Your request has been sent, you will receive an email on approval',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontFamily: 'Source Sans Pro',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 16),
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
                                        color:
                                            Color(0xFFF30802).withOpacity(0.1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
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
                              ),
                            ),
                          );
                        },
                      );
                    },
                    textColor: Colors.white,
                    gradientColors: [
                      AppColors.primaryBlack,
                      AppColors.primaryRed
                    ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
