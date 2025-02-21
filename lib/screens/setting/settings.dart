import 'package:bnn/screens/setting/blocked.dart';
import 'package:bnn/screens/setting/bnnPro.dart';
import 'package:bnn/screens/setting/edit.dart';
import 'package:bnn/screens/setting/mediaPreferences.dart';
import 'package:bnn/screens/setting/notifications.dart';
import 'package:bnn/screens/setting/permission.dart';
import 'package:bnn/screens/setting/visibility.dart';
import 'package:bnn/utils/colors.dart';
import 'package:bnn/widgets/buttons/button-gradient-main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final supabase = Supabase.instance.client;
  Future<void> signOutUser(BuildContext context) async {
    try {
      // Sign out from Supabase
      await supabase.auth.signOut();

      // Optionally, navigate to the login page or show a success message
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      // Handle any errors during sign-out
      print('Error signing out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          child: Text(
            "Settings",
            style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 20.0),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 8, top: 4, right: 8, bottom: 4),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(
                  left: 16, top: 12, right: 16, bottom: 12),
              decoration: BoxDecoration(
                color: Color(0xFFE9E9E9), // Grey background color
                borderRadius: BorderRadius.circular(8.0), // Border radius
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => BnnPro()));
                },
                child: Row(
                  children: [
                    Text(
                      'BNN Pro',
                      style: TextStyle(
                        color: Color(0xFF4D4C4A),
                        fontSize: 12,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        height: 1.06,
                        letterSpacing: -0.11,
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios,
                        size: 12, color: Color(0xFF8A8B8F)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.only(
                  left: 16, top: 12, right: 16, bottom: 12),
              decoration: BoxDecoration(
                color: Color(0xFFE9E9E9), // Grey background color
                borderRadius: BorderRadius.circular(15.0), // Border radius
              ),
              child: Column(children: [
                Column(children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditProfile()));
                    },
                    child: Row(
                      children: [
                        Text(
                          'Edit Profile',
                          style: TextStyle(
                            color: Color(0xFF4D4C4A),
                            fontSize: 12,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                            height: 1.06,
                            letterSpacing: -0.11,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios,
                            size: 12, color: Color(0xFF8A8B8F)),
                      ],
                    ),
                  ),
                  SizedBox(height: 4),
                  Divider(),
                  SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyVisibility()));
                    },
                    child: Row(
                      children: [
                        Text(
                          'My Visibility',
                          style: TextStyle(
                            color: Color(0xFF4D4C4A),
                            fontSize: 12,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                            height: 1.06,
                            letterSpacing: -0.11,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios,
                            size: 12, color: Color(0xFF8A8B8F)),
                      ],
                    ),
                  ),
                  SizedBox(height: 4),
                  Divider(),
                  SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Notifications()));
                    },
                    child: Row(
                      children: [
                        Text(
                          'Notifications',
                          style: TextStyle(
                            color: Color(0xFF4D4C4A),
                            fontSize: 12,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                            height: 1.06,
                            letterSpacing: -0.11,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios,
                            size: 12, color: Color(0xFF8A8B8F)),
                      ],
                    ),
                  ),
                  SizedBox(height: 4),
                  Divider(),
                  SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Permission()));
                    },
                    child: Row(
                      children: [
                        Text(
                          'Permissions',
                          style: TextStyle(
                            color: Color(0xFF4D4C4A),
                            fontSize: 12,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                            height: 1.06,
                            letterSpacing: -0.11,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios,
                            size: 12, color: Color(0xFF8A8B8F)),
                      ],
                    ),
                  ),
                  SizedBox(height: 4),
                  Divider(),
                  SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MediaPreferences()));
                    },
                    child: Row(
                      children: [
                        Text(
                          'Media Preferences',
                          style: TextStyle(
                            color: Color(0xFF4D4C4A),
                            fontSize: 12,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                            height: 1.06,
                            letterSpacing: -0.11,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios,
                            size: 12, color: Color(0xFF8A8B8F)),
                      ],
                    ),
                  ),
                  SizedBox(height: 4),
                  Divider(),
                  SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: [
                        Text(
                          'Community Standards',
                          style: TextStyle(
                            color: Color(0xFF4D4C4A),
                            fontSize: 12,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                            height: 1.06,
                            letterSpacing: -0.11,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios,
                            size: 12, color: Color(0xFF8A8B8F)),
                      ],
                    ),
                  ),
                  SizedBox(height: 4),
                  Divider(),
                  SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: [
                        Text(
                          'Privacy',
                          style: TextStyle(
                            color: Color(0xFF4D4C4A),
                            fontSize: 12,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                            height: 1.06,
                            letterSpacing: -0.11,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios,
                            size: 12, color: Color(0xFF8A8B8F)),
                      ],
                    ),
                  ),
                  SizedBox(height: 4),
                  Divider(),
                  SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: [
                        Text(
                          'Licenses',
                          style: TextStyle(
                            color: Color(0xFF4D4C4A),
                            fontSize: 12,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                            height: 1.06,
                            letterSpacing: -0.11,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios,
                            size: 12, color: Color(0xFF8A8B8F)),
                      ],
                    ),
                  ),
                  SizedBox(height: 4),
                  Divider(),
                  SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BlockedUsers()));
                    },
                    child: Row(
                      children: [
                        Text(
                          'Blocked Users',
                          style: TextStyle(
                            color: Color(0xFF4D4C4A),
                            fontSize: 12,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                            height: 1.06,
                            letterSpacing: -0.11,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios,
                            size: 12, color: Color(0xFF8A8B8F)),
                      ],
                    ),
                  ),
                ]),
              ]),
            ),
            SizedBox(height: 24),
            ButtonGradientMain(
              label: "LOG OUT",
              textColor: Colors.white,
              onPressed: () async {
                await signOutUser(context);
              },
              gradientColors: [AppColors.primaryBlack, AppColors.primaryRed],
            ),
          ],
        ),
      ),
    );
  }
}
