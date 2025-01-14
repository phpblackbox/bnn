import 'package:flutter/material.dart';

class Reels extends StatefulWidget {
  const Reels({Key? key}) : super(key: key);

  @override
  _ReelsState createState() => _ReelsState();
}

class _ReelsState extends State<Reels> {
  final List<dynamic> reels = [
    {
      'id': 1,
      'avatar': 'assets/images/avatar/s1.png',
      'name': 'Dennis Reynolds',
      'firstname': 'Dennis',
      'username': '@dennis',
      'time': '2 hrs ago',
      'content': 'AI Stadiums(part. 2)',
      'attach': 'assets/images/post/1.png',
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
      'content': "Networking",
      'like': '5.2K',
      'comment': '1.1K',
      'saved': '362',
      'backspace': '344',
      'attach': 'assets/images/post/3.png',
      'friend': 'Friends since February 2023'
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360.0, // Set a fixed height for the ListView
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: reels.length,
        itemBuilder: (context, index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(
                color: Colors.grey, // Color of the divider
                thickness: 1, // Thickness of the divider
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  height: 220,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(reels[index]['attach']),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: 10, right: 10, top: 10, bottom: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              reels[index]['avatar']!,
                              fit: BoxFit.fill,
                              width: 36,
                              height: 36,
                            ),
                            SizedBox(width: 5),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      reels[index]['name']!,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      reels[index]['username']!,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 10,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  reels[index]['time']!,
                                  style: TextStyle(
                                    color: Color(0xFFFFFFFF),
                                    fontSize: 10,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            GestureDetector(
                              onTap: () {
                                // _showFriendDetail(context, index);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Image.asset(
                                  'assets/images/icons/menu1.png', // Path to your image
                                  width: 20.0,
                                  height: 20.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Text(
                          reels[index]['content']!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.80,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 5.0, horizontal: 16.0),
                                decoration: ShapeDecoration(
                                  color: Color(0xFFE5E5E5).withOpacity(0.4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(35),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.favorite_border,
                                      color: Colors.white,
                                      size: 16.0,
                                    ),
                                    SizedBox(width: 4.0),
                                    Text(
                                      reels[index]['like']!,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 5.0,
                                    horizontal: 16.0), // Add padding
                                decoration: ShapeDecoration(
                                  color: Color(0xFFE5E5E5).withOpacity(0.4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(35),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.mode_comment_outlined,
                                      color: Colors.white,
                                      size: 16.0,
                                    ),
                                    SizedBox(width: 4.0),
                                    Text(
                                      reels[index]['comment']!,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Handle tap event
                                print('saved'); // Replace with your action
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 5.0,
                                    horizontal: 16.0), // Add padding
                                decoration: ShapeDecoration(
                                  color: Color(0xFFE5E5E5).withOpacity(0.4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(35),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .center, // Center items horizontally
                                  children: <Widget>[
                                    Icon(
                                      Icons.bookmark_outline,
                                      color: Colors.white, // Icon color
                                      size:
                                          16.0, // Adjustable size for the icon
                                    ),
                                    SizedBox(
                                        width:
                                            4.0), // Spacing between icon and text
                                    Text(
                                      reels[index][
                                          'saved']!, // Customize the label as needed
                                      style: TextStyle(
                                        color: Colors
                                            .white, // Set text color to contrast with the background
                                        fontSize: 12.0, // Set font size
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Handle tap event
                                print('bakspace'); // Replace with your action
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 5.0,
                                    horizontal: 16.0), // Add padding
                                decoration: ShapeDecoration(
                                  color: Color(0xFFE5E5E5).withOpacity(0.4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(35),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .center, // Center items horizontally
                                  children: <Widget>[
                                    Icon(
                                      Icons
                                          .forward, // Replace with your desired icon
                                      color: Colors.white, // Icon color
                                      size:
                                          16.0, // Adjustable size for the icon
                                    ),
                                    SizedBox(
                                        width:
                                            4.0), // Spacing between icon and text
                                    Text(
                                      reels[index][
                                          'backspace']!, // Customize the label as needed
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
