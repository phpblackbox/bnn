import 'package:bnn/screens/chat/chat.dart';
import 'package:bnn/screens/signup/CustomInputField.dart';
import 'package:flutter/material.dart';

class ChatList extends StatefulWidget {
  const ChatList({Key? key}) : super(key: key);

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final TextEditingController searchController = TextEditingController();
  final List<dynamic> data = [
    {
      'id': '1',
      'avatar': 'assets/images/avatar/p1.png',
      'name': 'Jason bosch',
      'content': 'Hey, how’s it goin?'
    },
    {
      'id': '1',
      'avatar': 'assets/images/avatar/p3.png',
      'name': 'Jakob Curtis',
      'content': 'Yo, how are you doing?'
    },
    {
      'id': '1',
      'avatar': 'assets/images/avatar/p4.png',
      'name': 'Abram Levin',
      'content': 'There is a new AI image generator software i use now'
    },
    {
      'id': '1',
      'avatar': 'assets/images/avatar/p5.png',
      'name': 'Marilyn Herwitz',
      'content': 'hey, i got new Pictures for you'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            child: CustomInputField(
              placeholder: "Search for friends",
              controller: searchController,
              onChanged: (value) {
                setState(() {}); // Update state on input field change
              },
              icon: Icons.search,
            ),
          ),
          Container(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: data.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.all(8),
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black,
                        Color(0xFF800000),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Chat()));
                    },
                    child: Row(
                      children: [
                        Image.asset(
                          data[index]['avatar']!,
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
                              Text(
                                data[index]['name']!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "Poppins",
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                data[index]['content']!,
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
        ],
      ),
    );
  }
}
