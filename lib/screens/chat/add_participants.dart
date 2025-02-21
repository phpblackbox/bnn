import 'package:bnn/utils/constants.dart';
import 'package:bnn/widgets/inputs/custom-input-field.dart';
import 'package:flutter/material.dart';

class AddParticipants extends StatefulWidget {
  const AddParticipants({super.key});

  @override
  State<AddParticipants> createState() => _AddParticipantsState();
}

class _AddParticipantsState extends State<AddParticipants> {
  final TextEditingController searchController = TextEditingController();

  final List<dynamic> data = Constants.fakeAddParticipants;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          child: Text(
            "Add Participants",
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
        padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
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
            SizedBox(height: 16),
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(children: [
                        Image(
                            image: AssetImage("assets/images/icons/invite.png"),
                            width: 40,
                            height: 40),
                        SizedBox(width: 10),
                        Text(
                          'Invite friends',
                          style: TextStyle(
                            color: Color(0xFF4D4C4A),
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ]),
                    ),
                    Icon(Icons.arrow_forward_ios,
                        size: 12, color: Color(0xFF8A8B8F)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Row(children: [
                        Image(
                            image: AssetImage("assets/images/icons/find.png"),
                            width: 40,
                            height: 40),
                        SizedBox(width: 10),
                        Text(
                          'Find contacts',
                          style: TextStyle(
                            color: Color(0xFF4D4C4A),
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ]),
                    ),
                    Icon(Icons.arrow_forward_ios,
                        size: 12, color: Color(0xFF8A8B8F)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Row(children: [
                        Image(
                            image:
                                AssetImage("assets/images/icons/facebook.png"),
                            width: 40,
                            height: 40),
                        SizedBox(width: 10),
                        Text(
                          'Find Facebook friends',
                          style: TextStyle(
                            color: Color(0xFF4D4C4A),
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ]),
                    ),
                    Icon(Icons.arrow_forward_ios,
                        size: 12, color: Color(0xFF8A8B8F)),
                  ],
                ),
                SizedBox(height: 8),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Friends',
              style: TextStyle(
                color: Color(0xFF4D4C4A),
                fontSize: 15,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.only(bottom: 12),
                    // margin: EdgeInsets.all(8),
                    child: GestureDetector(
                      onTap: () {
                        // Navigator.push(context,
                        //     MaterialPageRoute(builder: (context) => Chat()));
                      },
                      child: Row(
                        children: [
                          Image.asset(
                            data[index]['avatar']!,
                            fit: BoxFit.fill,
                            width: 50,
                            height: 50,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data[index]['name'],
                                  style: TextStyle(
                                    color: Color(0xFF4D4C4A),
                                    fontSize: 12,
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w700,
                                    height: 1.50,
                                  ),
                                ),
                                Text(
                                  data[index]['mutal']!,
                                  style: TextStyle(
                                    color: Color(0xFF4D4C4A),
                                    fontFamily: "Poppins",
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: ImageIcon(
                              AssetImage('assets/images/icons/menu.png'),
                              color: Color(0xFF4D4C4A),
                              size: 16,
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
      ),
    );
  }
}
