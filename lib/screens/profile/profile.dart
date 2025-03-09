import 'dart:io';

import 'package:bnn/providers/auth_provider.dart';
import 'package:bnn/widgets/sub/bottom-navigation.dart';
import 'package:bnn/screens/home/posts.dart';
import 'package:bnn/screens/profile/all.dart';
import 'package:bnn/screens/profile/followers.dart';
import 'package:bnn/screens/setting/edit.dart';
import 'package:bnn/screens/setting/settings.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final supabase = Supabase.instance.client;

  int _followers = 0;
  int _posts = 0;
  int _views = 124;
  bool _loading = true;
  int _allorbookmark = 0;

  @override
  void initState() {
    super.initState();
    fetchdata();
  }

  void fetchdata() async {
    final AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    final meId = authProvider.profile!.id;

    int data = await supabase.rpc('get_count_follower', params: {
          'param_followed_id': meId,
        }) ??
        0;
    setState(() {
      _followers = data;
    });

    final temp = await supabase
        .from('profiles')
        .select('views')
        .eq('id', meId.toString())
        .single();

    setState(() {
      _views = temp['views'];
    });

    data = await supabase.rpc('get_count_posts', params: {
          'param_user_id': meId,
        }) ??
        0;

    setState(() {
      _posts = data;
      _loading = false;
    });
  }

  void _onAllOrSave(int index) {
    setState(() {
      _allorbookmark = index; // Update the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = Provider.of<AuthProvider>(context);
    final meProfile = authProvider.profile!;

    var currentTime;
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
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
            child: Column(
          children: [
            Container(
              height: 330,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/profile/rect.png"),
                  fit: BoxFit.fill,
                ),
              ),
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 32, right: 16),
                    child: Row(
                      children: [
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            print("hello");
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Settings()));
                          },
                          child: Image(
                            image:
                                AssetImage('assets/images/icons/setting2.png'),
                            width: 32,
                            height: 32,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundImage: NetworkImage(meProfile.avatar!),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EditProfile()));
                          },
                          child: Image(
                            image: AssetImage('assets/images/icons/edit.png'),
                            width: 32,
                            height: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        meProfile.getFullName(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8),
                      ImageIcon(
                        AssetImage(
                            'assets/images/icons/verified.png'), // Replace with your image path
                        size: 16, // Set the size of the icon
                        color: Colors.white, // Set the color of the icon
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    meProfile.username!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 10),
                  Skeletonizer(
                    enabled: _loading,
                    enableSwitchAnimation: true,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text(
                              'Posts',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              _posts.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 8),
                        Container(
                          width: 1,
                          height: 47,
                          decoration: BoxDecoration(
                            color:
                                Colors.white.withOpacity(0.15000000596046448),
                          ),
                        ),
                        SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Followers()));
                          },
                          child: Column(
                            children: [
                              Text(
                                'Followers',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                _followers.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          width: 1,
                          height: 47,
                          decoration: BoxDecoration(
                            color:
                                Colors.white.withOpacity(0.15000000596046448),
                          ),
                        ),
                        SizedBox(width: 8),
                        Column(
                          children: [
                            Text(
                              'Views',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              _views.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              )),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    _onAllOrSave(0);
                  },
                  child: ImageIcon(
                    AssetImage('assets/images/icons/all.png'),
                    color: _allorbookmark == 0
                        ? Colors.black
                        : Colors.black.withOpacity(0.5),
                    size: 24,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _onAllOrSave(1);
                  },
                  child: ImageIcon(
                    AssetImage('assets/images/icons/bookmark.png'),
                    color: _allorbookmark == 1
                        ? Colors.black.withOpacity(1)
                        : Colors.black.withOpacity(0.5),
                    size: 24,
                  ),
                ),
              ],
            ),
            if (_allorbookmark == 0)
              AllPost(param_allorbookmakr: _allorbookmark),
            if (_allorbookmark == 1)
              Expanded(
                child: Container(
                    padding: EdgeInsets.only(left: 12, right: 12, bottom: 8),
                    child: Posts(bookmark: true)),
              ),
          ],
        )),
        bottomNavigationBar: BottomNavigation(currentIndex: 4),
      ),
    );
  }
}
