import 'package:bnn/widgets/inputs/input-with-emoji.dart';
import 'package:bnn/screens/live/liveEnd.dart';
import 'package:flutter/material.dart';

class LiveDash extends StatefulWidget {
  const LiveDash({super.key});

  @override
  _LiveDashState createState() => _LiveDashState();
}

class _LiveDashState extends State<LiveDash> {
  final dynamic profile = {
    "name": "Charlie Kelly",
    "view": 400,
    "like": "700.2k"
  };

  final dynamic comments = [
    {
      'id': 1,
      'avatar': 'assets/images/avatar/p1.png',
      'name': 'John Smith',
      'text': 'Joined the Live',
    },
    {
      'id': 1,
      'avatar': 'assets/images/avatar/p3.png',
      'name': 'Cole Mcgee',
      'text': "Lorem Ipsum has been the industry's standard",
    },
    {
      'id': 1,
      'avatar': 'assets/images/avatar/p4.png',
      'name': 'Olivia',
      'text': 'Lorem Ipsum has been ',
    },
    {
      'id': 1,
      'avatar': 'assets/images/avatar/p5.png',
      'name': 'Andrea',
      'text': 'Lorem Ipsum has been the ',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Customize according to your theme

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
            top: 20,
            left: 10,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LiveDash()));
                  },
                  child: Image(
                    image: AssetImage("assets/images/live/p2.png"),
                    width: 50,
                    height: 50,
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Charlie Kelly',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w600,
                        height: 1.13,
                        letterSpacing: -0.11,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.remove_red_eye_outlined,
                            color: Colors.white, size: 13),
                        SizedBox(width: 3),
                        Text(
                          '${profile['view']} View',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 7,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {},
                          child: ImageIcon(
                            AssetImage('assets/images/icons/heart2.png'),
                            color: Colors.white,
                            size: 13,
                          ),
                        ),
                        SizedBox(width: 3),
                        Text(
                          profile["like"] + ' Likes',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 7,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 20, // Adjust this value to change vertical position
            right: 10, // Adjust this value to change horizontal position
            child: GestureDetector(
              onTap: () {
                // Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => liveEnd()));
              },
              child: Image(
                image: AssetImage("assets/images/live/close.png"),
                width: 45,
                height: 45,
              ),
            ),
          ),
          Positioned(
            top: 80,
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
                  ],
                ),
                SizedBox(height: 15),
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: ImageIcon(
                        AssetImage('assets/images/icons/person.png'),
                        color: Colors.white,
                        size: 27,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: ImageIcon(
                        AssetImage('assets/images/icons/magic.png'),
                        color: Colors.white,
                        size: 27,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: ImageIcon(
                        AssetImage('assets/images/icons/back.png'),
                        color: Colors.white,
                        size: 27,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(children: [
              SizedBox(
                height: 200,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.all(8),
                      child: GestureDetector(
                        onTap: () {},
                        child: Row(
                          children: [
                            Image.asset(
                              comments[index]['avatar']!,
                              fit: BoxFit.fill,
                              width: 45,
                              height: 45,
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    comments[index]['name']!,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: "Poppins",
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    comments[index]['text']!,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.63),
                                      fontFamily: "Poppins",
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0), // Adjust padding as needed
                child: Row(
                  children: [
                    Expanded(
                      child: InputWithEmoji(), // Your input widget
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(
                            context); // Action when the button is tapped
                      },
                      child: Image(
                        image: AssetImage("assets/images/live/like_btn.png"),
                        width: 45,
                        height: 45,
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
