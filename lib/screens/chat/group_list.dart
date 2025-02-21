import 'package:bnn/screens/chat/add_participants.dart';
import 'package:bnn/screens/chat/group.dart';
import 'package:bnn/widgets/inputs/custom-input-field.dart';
import 'package:flutter/material.dart';

class GroupList extends StatefulWidget {
  const GroupList({super.key});

  @override
  _GroupListState createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  final TextEditingController searchController = TextEditingController();
  final List<dynamic> data = [
    {
      'id': '1',
      'avatar': 'assets/images/avatar/p1.png',
      'name': 'Uk Guys',
      'content': 'Peter: Happy Sunday'
    },
    {
      'id': '1',
      'avatar': 'assets/images/avatar/p3.png',
      'name': 'Football Group',
      'content': 'John: Yo, how are you doing?'
    },
    {
      'id': '1',
      'avatar': 'assets/images/avatar/p4.png',
      'name': 'Design Team',
      'content': 'Duke: There is a new AI image generator software i use now'
    },
    {
      'id': '1',
      'avatar': 'assets/images/avatar/p5.png',
      'name': 'Development Team',
      'content': 'Senior dev: hey, i got new Pictures for you'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            child: CustomInputField(
              placeholder: "Search for groups",
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
                          MaterialPageRoute(builder: (context) => Group()));
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
          Row(
            children: [
              Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddParticipants()));
                },
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Image.asset(
                    'assets/images/group_create_btn.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
