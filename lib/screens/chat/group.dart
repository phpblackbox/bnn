import 'package:bnn/screens/chat/GroupVideoCall.dart';
import 'package:bnn/screens/chat/GroupVoiceCall.dart';
import 'package:flutter/material.dart';

class Group extends StatefulWidget {
  const Group({super.key});

  @override
  _GroupState createState() => _GroupState();
}

class Message {
  final String sender;
  final String text;
  final String time;
  final bool isMe;

  Message(
      {required this.sender,
      required this.time,
      required this.text,
      required this.isMe});
}

class _GroupState extends State<Group> {
  final List<Message> messages = [
    Message(
        sender: 'Jakob',
        time: '2:55 PM',
        text: 'Lorem Ipsum is simply dummy text of the printing',
        isMe: false),
    Message(sender: 'John', time: '3:02 PM', text: 'Yes', isMe: false),
    Message(sender: 'Me', time: '3:02 PM', text: 'I’m prepared', isMe: true),
  ];

  final TextEditingController _controller = TextEditingController();

  void _showMenuModal(BuildContext context) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final size = overlay.size;

    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(size.width - 100, 0, 0, size.height),
      items: [
        PopupMenuItem<int>(
          value: 1,
          child: Column(children: [
            Row(children: [
              Icon(Icons.cancel_outlined, color: Color(0xFF4D4C4A)),
              SizedBox(width: 10),
              Text(
                'Clear History',
                style: TextStyle(color: Color(0xFF4D4C4A)),
              )
            ]),
            Divider()
          ]),
        ),
        PopupMenuItem<int>(
          value: 3,
          child: Column(children: [
            Row(children: [
              Icon(Icons.search, color: Color(0xFF4D4C4A)),
              SizedBox(width: 10),
              Text(
                'Search Group',
                style: TextStyle(color: Color(0xFF4D4C4A)),
              )
            ]),
            Divider()
          ]),
        ),
        PopupMenuItem<int>(
          value: 4,
          child: Column(children: [
            Row(children: [
              Icon(Icons.exit_to_app, color: Color(0xFF4D4C4A)),
              SizedBox(width: 10),
              Text(
                'Exit Group',
                style: TextStyle(color: Color(0xFF4D4C4A)),
              )
            ]),
            Divider()
          ]),
        ),
        PopupMenuItem<int>(
          value: 5,
          child: Column(children: [
            Row(children: [
              Icon(Icons.bug_report_outlined, color: Color(0xFF4D4C4A)),
              SizedBox(width: 10),
              Text(
                'Report User',
                style: TextStyle(color: Color(0xFF4D4C4A)),
              )
            ]),
          ]),
        ),
      ],
    ).then((value) {
      if (value != null) {
        // Handle the selected option here
        print('Selected option: $value');
      }
    });
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        messages.add(Message(
            sender: 'Me', time: '3:15 PM', text: _controller.text, isMe: true));
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white, // Customize according to your theme
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(180), // Set your desired height here
          child: Container(
            margin: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black, // Start color
                    Color(0xFF820200), // End color
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20.0)),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      size: 20.0,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.local_phone,
                          size: 20.0,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GroupVoiceCall()));
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.video_camera_back_outlined,
                          size: 20.0,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GroupVideoCall()));
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.menu,
                          size: 20.0,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          _showMenuModal(context);
                        },
                      ),
                    ],
                  )
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/avatar/message_man.png",
                    fit: BoxFit.fill,
                    height: 100, // This is the height of the image
                  ),
                  Column(
                    // mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Design Team',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        '3 participants',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.62),
                          fontSize: 10,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  )
                ],
              )
            ]),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return Align(
                    alignment: message.isMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(15),
                          bottomLeft: message.isMe
                              ? Radius.circular(15)
                              : Radius.circular(0),
                          bottomRight: message.isMe
                              ? Radius.circular(0)
                              : Radius.circular(15),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            message.sender,
                            style: TextStyle(
                                color: Colors.black.withOpacity(0.7),
                                fontSize: 10),
                          ),
                          SizedBox(height: 5),
                          Text(
                            message.text,
                            style: TextStyle(color: Colors.black, fontSize: 10),
                          ),
                          SizedBox(height: 5), // Space between text and time
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                message.time,
                                style:
                                    TextStyle(fontSize: 8, color: Colors.grey),
                              ),
                              SizedBox(width: 16),
                              if (message.isMe)
                                Icon(
                                  Icons.done_all_outlined,
                                  color: Color(0xFFF30802),
                                  size: 12,
                                ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 10, right: 10, bottom: 15),
              height: 60.0,
              decoration: BoxDecoration(
                color: Color(0xFFEAEAEA),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: TextField(
                style: TextStyle(fontSize: 12.0, fontFamily: "Poppins"),
                controller: _controller,
                obscureText: false,
                onChanged: (value) {
                  setState(() {}); // Update state on email field change
                },
                decoration: InputDecoration(
                  hintText: "Write a message...",
                  hintStyle: TextStyle(color: Color(0x99898989)),
                  suffixIcon: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.mic),
                        color: Colors.black.withOpacity(0.7),
                        iconSize: 40.0,
                        onPressed: () {
                          // Action when button is pressed
                          print("Volume Up Pressed");
                        },
                      ),
                      GestureDetector(
                        onTap: () {
                          _sendMessage();
                        },
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: Image.asset(
                            'assets/images/message_send_btn.png',
                            fit: BoxFit.fill,
                          ),
                        ),
                      )
                    ],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(color: Color(0xFF898989)),
                  ),
                  filled: true,
                  fillColor: Color(0xFFEAEAEA),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                ),
              ),
            )
          ],
        ));
  }
}
