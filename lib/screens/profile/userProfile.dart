import 'package:bnn/screens/chat/chat.dart';
import 'package:bnn/screens/home/postView.dart';
import 'package:bnn/screens/profile/followers.dart';
import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final dynamic data = {
    "username": "John\nSmith",
    "post_count": 35,
    "follower": 6552,
    "view": 128,
    "about":
        "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s",
    "year": "20yrs",
    "marital": "Married",
    "nationality": "African-American",
    "location": "United States, California",
    "content": "Content Creator",
    "post": [
      {
        'id': 1,
        'avatar': 'assets/images/avatar/s1.png',
        'name': 'Dennis Reynolds',
        'firstname': 'Dennis',
        'username': '@dennis',
        'time': '2 hrs ago',
        'content': 'AI Stadiums(part. 2)',
        'attach': ['assets/images/post/1.png', 'assets/images/post/2.png'],
        'like': '5.2K',
        'comment': '1.1K',
        'saved': '362',
        'backspace': '344',
        'friend': 'Friends since February 2023'
      },
      {
        'id': 2,
        'avatar': 'assets/images/avatar/s2.png',
        'name': 'Charlie Kelly',
        'firstname': 'Charlie',
        'username': '@charlie',
        'time': '4hrs ago',
        'content':
            "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s. When an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged.",
        'like': '5.2K',
        'comment': '1.1K',
        'saved': '362',
        'backspace': '344',
        'attach': [],
        'friend': 'Friends since February 2023'
      }
    ]
  };

  String formatWithCommas(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(4),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(16), // Clip with rounded corners
                  child: Column(
                    children: [
                      Stack(
                        children: <Widget>[
                          Container(
                            width: double.infinity,
                            height: 400,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: AssetImage(
                                    'assets/images/avatar/userprofile1.png'),
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: 400,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              gradient: LinearGradient(
                                begin: FractionalOffset.topCenter,
                                end: FractionalOffset.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withOpacity(1),
                                ],
                                stops: [0.5, 1.0],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: IconButton(
                              icon: Icon(Icons.close, color: Colors.white),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 8,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  data["username"],
                                  style: TextStyle(
                                    color: Color(0xFF4D4C4A),
                                    fontSize: 30,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w400,
                                    height: 1.06,
                                    letterSpacing: 1,
                                  ),
                                ),
                                SizedBox(width: 5, height: 15),
                                ImageIcon(
                                  AssetImage(
                                      'assets/images/icons/verified.png'),
                                  color: Colors.red,
                                  size: 16.0,
                                ),
                                SizedBox(width: 35),
                                Row(children: [
                                  Column(
                                    children: [
                                      Text(
                                        'Posts',
                                        style: TextStyle(
                                          color: Color(0xFF4D4C4A),
                                          fontSize: 14,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        data["post_count"].toString(),
                                        style: TextStyle(
                                          color: Color(0xFF4D4C4A),
                                          fontSize: 20,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Followers()));
                                    },
                                    child: Column(
                                      children: [
                                        Text(
                                          'Followers',
                                          style: TextStyle(
                                            color: Color(0xFF4D4C4A),
                                            fontSize: 14,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          formatWithCommas(data["follower"])
                                              .toString(),
                                          style: TextStyle(
                                            color: Color(0xFF4D4C4A),
                                            fontSize: 20,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Column(
                                    children: [
                                      Text(
                                        'Views',
                                        style: TextStyle(
                                          color: Color(0xFF4D4C4A),
                                          fontSize: 14,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        data["view"].toString(),
                                        style: TextStyle(
                                          color: Color(0xFF4D4C4A),
                                          fontSize: 20,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(width: 10),
                                ]),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // about and ...
              Container(
                padding: EdgeInsets.all(8),
                child: Column(children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Text(
                        'ABOUT',
                        style: TextStyle(
                          color: Color(0xFF4D4C4A),
                          fontSize: 14,
                          fontFamily: 'Abel',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        data['about'],
                        style: TextStyle(
                          color: Color(0xFF4D4C4A),
                          fontSize: 12,
                          fontFamily: 'Abel',
                          fontWeight: FontWeight.w400,
                          height: 1.50,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ImageIcon(
                                AssetImage(
                                    'assets/images/icons/speedometer.png'),
                                size: 22.0,
                                color: Color(0xFF4D4C4A),
                              ),
                              SizedBox(width: 8),
                              Text(
                                data["year"],
                                style: TextStyle(
                                  color: Color(0xFF4D4C4A),
                                  fontSize: 12,
                                  fontFamily: 'Abel',
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              ImageIcon(
                                AssetImage('assets/images/icons/heart.png'),
                                size: 22.0,
                                color: Color(0xFF4D4C4A),
                              ),
                              SizedBox(width: 8),
                              Text(
                                data["marital"],
                                style: TextStyle(
                                  color: Color(0xFF4D4C4A),
                                  fontSize: 12,
                                  fontFamily: 'Abel',
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              ImageIcon(
                                AssetImage('assets/images/icons/flag.png'),
                                size: 22.0,
                                color: Color(0xFF4D4C4A),
                              ),
                              SizedBox(width: 8),
                              Text(
                                data["nationality"],
                                style: TextStyle(
                                  color: Color(0xFF4D4C4A),
                                  fontSize: 12,
                                  fontFamily: 'Abel',
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              ImageIcon(
                                AssetImage('assets/images/icons/location.png'),
                                size: 22.0,
                                color: Color(0xFF4D4C4A),
                              ),
                              SizedBox(width: 8),
                              Text(
                                data["location"],
                                style: TextStyle(
                                  color: Color(0xFF4D4C4A),
                                  fontSize: 12,
                                  fontFamily: 'Abel',
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              ImageIcon(
                                AssetImage('assets/images/icons/content.png'),
                                size: 22.0,
                                color: Color(0xFF4D4C4A),
                              ),
                              SizedBox(width: 8),
                              Text(
                                data["content"],
                                style: TextStyle(
                                  color: Color(0xFF4D4C4A),
                                  fontSize: 12,
                                  fontFamily: 'Abel',
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                              onTap: () => {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Chat()))
                                  },
                              child: Image.asset(
                                'assets/images/profile_msg_btn.png',
                                width: 75,
                                height: 75,
                              )),
                        ],
                      )
                    ],
                  ),
                ]),
              ),

              // Posts
              Padding(
                padding: EdgeInsets.only(left: 16, top: 0, right: 16),
                child: PostView(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
