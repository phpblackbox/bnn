import 'package:flutter/material.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final dynamic data = {
    'today': [
      {
        'avatar': 'assets/images/avatar/p4.png',
        'name': 'Cole McGee',
        'content': "Liked your post",
        // 0: Liked your post, 1: Followed you, 2: Commented on your post
      },
      {
        'avatar': 'assets/images/avatar/p5.png',
        'name': 'Peter',
        'content': "Followed you"
      },
      {
        'avatar': 'assets/images/avatar/p6.png',
        'name': 'Johnson',
        'content': "Liked your post" // 0: Liked your post 1: Followed you
      },
    ],
    'yesterday': [
      {
        'avatar': 'assets/images/avatar/p7.png',
        'name': 'Jeremy',
        'content': "Liked your post"
      },
      {
        'avatar': 'assets/images/avatar/p8.png',
        'name': 'John',
        'content': "Followed you"
      },
      {
        'avatar': 'assets/images/avatar/p3.png',
        'name': 'Derrick',
        'content': "Liked your post"
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          child: Text(
            "Notificaitons",
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
      body: Padding(
        padding: const EdgeInsets.only(left: 16, top: 4, right: 16, bottom: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today',
              style: TextStyle(
                color: Color(0xFF4D4C4A),
                fontSize: 15,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: data["today"].length,
                itemBuilder: (context, index) {
                  return Container(
                    child: Row(
                      children: [
                        Image.asset(
                          data["today"][index]['avatar']!,
                          fit: BoxFit.fill,
                          width: 50,
                          height: 50,
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Text(
                                  data["today"][index]['name']!,
                                  style: TextStyle(
                                      color: Color(0xFF8A8B8F),
                                      fontFamily: "Nunito",
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ]),
                              SizedBox(height: 10),
                              Text(
                                data["today"][index]['content']!,
                                style: TextStyle(
                                    color: Color(0xFF8A8B8F),
                                    fontFamily: "Nunito",
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Icon(Icons.arrow_forward_ios,
                                size: 12, color: Color(0xFF8A8B8F)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Text(
              'yesterday',
              style: TextStyle(
                color: Color(0xFF4D4C4A),
                fontSize: 15,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: data["yesterday"].length,
                itemBuilder: (context, index) {
                  return Container(
                    child: Row(
                      children: [
                        Image.asset(
                          data["yesterday"][index]['avatar']!,
                          fit: BoxFit.fill,
                          width: 50,
                          height: 50,
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Text(
                                  data["yesterday"][index]['name']!,
                                  style: TextStyle(
                                      color: Color(0xFF8A8B8F),
                                      fontFamily: "Nunito",
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ]),
                              SizedBox(height: 10),
                              Text(
                                data["yesterday"][index]['content']!,
                                style: TextStyle(
                                    color: Color(0xFF8A8B8F),
                                    fontFamily: "Nunito",
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Icon(Icons.arrow_forward_ios,
                                size: 12, color: Color(0xFF8A8B8F)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
