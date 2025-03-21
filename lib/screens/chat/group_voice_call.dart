import 'package:bnn/screens/chat/call_bottom.dart';
import 'package:flutter/material.dart';

class GroupVoiceCall extends StatefulWidget {
  const GroupVoiceCall({super.key});

  @override
  _GroupVoiceCallState createState() => _GroupVoiceCallState();
}

class _GroupVoiceCallState extends State<GroupVoiceCall> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: <Widget>[
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'John Doe',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Duration: 12:34',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          CircleAvatar(
                            radius: 40,
                            backgroundImage:
                                AssetImage('assets/images/avatar/p2.png'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'John Doe',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Duration: 12:34',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          CircleAvatar(
                            radius: 40,
                            backgroundImage:
                                AssetImage('assets/images/avatar/p2.png'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'John Doe',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Duration: 12:34',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          CircleAvatar(
                            radius: 40,
                            backgroundImage:
                                AssetImage('assets/images/avatar/p2.png'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'John Doe',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Duration: 12:34',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          CircleAvatar(
                            radius: 40,
                            backgroundImage:
                                AssetImage('assets/images/avatar/p2.png'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: CallBottom(),
      ),
    );
  }
}
