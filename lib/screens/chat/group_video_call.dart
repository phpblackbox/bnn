import 'package:bnn/screens/chat/call_bottom.dart';
import 'package:flutter/material.dart';

class GroupVideoCall extends StatefulWidget {
  const GroupVideoCall({super.key});

  @override
  _GroupVideoCallState createState() => _GroupVideoCallState();
}

class _GroupVideoCallState extends State<GroupVideoCall> {
  @override
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(children: [
          Column(
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
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/call1.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
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
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/call2.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
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
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/call3.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
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
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/call4.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
              bottom: 20,
              right: 10,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(0xFFF30802),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Image.asset(
                  'assets/images/call2.png',
                  height: 150,
                ),
              )),
        ]),
        bottomNavigationBar: CallBottom(),
      ),
    );
  }
}
