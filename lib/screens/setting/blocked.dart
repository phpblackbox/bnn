import 'package:bnn/widgets/inputs/custom-input-field.dart';
import 'package:flutter/material.dart';

class BlockedUsers extends StatefulWidget {
  const BlockedUsers({super.key});

  @override
  State<BlockedUsers> createState() => _BlockedUsersState();
}

class _BlockedUsersState extends State<BlockedUsers> {
  final TextEditingController searchController = TextEditingController();

  final dynamic _selectedUsers = [
    {'id': 1, 'content': 'John smith', 'status': true},
    {'id': 2, 'content': 'Rhoini', 'status': false},
    {'id': 3, 'content': 'Johnson', 'status': false},
    {'id': 3, 'content': 'Israel', 'status': false},
    {'id': 3, 'content': 'Williams', 'status': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(top: 48, left: 16, right: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back,
                      size: 20.0, color: Color(0xFF4D4C4A)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(width: 5),
                Text(
                  'Blocked Users',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF4D4C4A),
                    fontSize: 14,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
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
            SizedBox(height: 25),
            Expanded(
              child: Container(
                // padding: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Color(0xFFE9E9E9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListView.builder(
                  itemCount: _selectedUsers.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(
                              left: 14, top: 6, bottom: 6, right: 14),
                          child: Row(
                            children: [
                              Text(
                                _selectedUsers[index]['content'],
                                style: TextStyle(
                                  color: Color(0xFF4D4C4A),
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Spacer(),
                              GestureDetector(
                                onTap: () {},
                                child: ImageIcon(
                                  AssetImage('assets/images/icons/disable.png'),
                                  color: Color(0xFF4D4C4A),
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (index != _selectedUsers.length - 1) Divider(),
                      ],
                    );
                  },
                ),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
