import 'package:bnn/main.dart';
import 'package:bnn/models/profiles.dart';
import 'package:bnn/screens/chat/ChatView.dart';
import 'package:bnn/screens/home/createPost.dart';
import 'package:bnn/screens/home/header.dart';
import 'package:bnn/screens/home/home.dart';
import 'package:bnn/screens/home/postView.dart';
import 'package:bnn/screens/live/live.dart';
import 'package:bnn/screens/profile/all.dart';
import 'package:bnn/screens/profile/followers.dart';
import 'package:bnn/screens/setting/edit.dart';
import 'package:bnn/screens/setting/settings.dart';
import 'package:bnn/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int _followers = 0;
  int _posts = 0;
  int _views = 124;
  bool _loading = true;
  int _allorbookmark = 0; // 0: all, 1; save

  Profiles? loadedProfile;
  @override
  void initState() {
    super.initState();
    fetchdata();
  }

  void fetchdata() async {
    final res = await Constants.loadProfile();

    setState(() {
      loadedProfile = res;
    });

    int data = await supabase.rpc('get_count_follower', params: {
          'param_followed_id': loadedProfile!.id,
        }) ??
        0;
    setState(() {
      _followers = data;
    });

    final temp = await supabase
        .from('profiles')
        .select('views')
        .eq('id', loadedProfile!.id)
        .single();

    setState(() {
      _views = temp['views'];
    });

    data = await supabase.rpc('get_count_posts', params: {
          'param_user_id': loadedProfile!.id,
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

  void _onBottomNavigationTapped(int index) {
    if (index == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
    }
    if (index == 1) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ChatView()));
    }
    if (index == 2) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreatePost()));
    }
    if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Live()));
    }
    if (index == 4) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Profile()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: loadedProfile != null
            ? Column(
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
                                  image: AssetImage(
                                      'assets/images/icons/setting2.png'),
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
                              backgroundImage:
                                  NetworkImage(loadedProfile!.avatar),
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
                                  image: AssetImage(
                                      'assets/images/icons/edit.png'),
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
                              loadedProfile!.getFullName(),
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
                          loadedProfile!.username,
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
                                  color: Colors.white
                                      .withOpacity(0.15000000596046448),
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
                                  color: Colors.white
                                      .withOpacity(0.15000000596046448),
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
                          padding:
                              EdgeInsets.only(left: 12, right: 12, bottom: 8),
                          child: PostView(bookmark: true)),
                    ),
                ],
              )
            : null,
      ),
      bottomNavigationBar: SizedBox(
        height: 67.0,
        child: Padding(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                  onTap: () => _onBottomNavigationTapped(0),
                  child: Image.asset(
                    'assets/images/icons/home.png',
                    width: 20,
                    height: 20,
                  )),
              GestureDetector(
                  onTap: () => _onBottomNavigationTapped(1),
                  child: Image.asset(
                    'assets/images/icons/comment.png',
                    width: 20,
                    height: 20,
                  )),
              GestureDetector(
                onTap: () => _onBottomNavigationTapped(2),
                child: Image.asset(
                  'assets/images/navigation_add_post.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              GestureDetector(
                  onTap: () => _onBottomNavigationTapped(3),
                  child: Image.asset(
                    'assets/images/icons/video.png',
                    width: 20,
                    height: 20,
                  )),
              GestureDetector(
                  onTap: () => _onBottomNavigationTapped(4),
                  child: Image.asset(
                    'assets/images/icons/user_active.png',
                    width: 20,
                    height: 20,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
