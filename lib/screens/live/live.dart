import 'package:bnn/screens/chat/ChatView.dart';
import 'package:bnn/screens/home/createPost.dart';
import 'package:bnn/screens/home/home.dart';
import 'package:bnn/screens/live/liveDash.dart';
import 'package:bnn/screens/profile/profile.dart';
import 'package:flutter/material.dart';

class Live extends StatefulWidget {
  const Live({Key? key}) : super(key: key);

  @override
  _LiveState createState() => _LiveState();
}

class _LiveState extends State<Live> {
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

      bottomNavigationBar: Container(
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
                    'assets/images/icons/video_active.png',
                    width: 20,
                    height: 20,
                  )),
              GestureDetector(
                  onTap: () => _onBottomNavigationTapped(4),
                  child: Image.asset(
                    'assets/images/icons/user.png',
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
