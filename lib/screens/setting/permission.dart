import 'package:flutter/material.dart';

class Permission extends StatefulWidget {
  const Permission({super.key});

  @override
  State<Permission> createState() => _PermissionState();
}

class _PermissionState extends State<Permission> {
  bool _isLocationServices = false;
  bool _isUploadContacts = false;
  bool _isCameraAccess = false;
  bool _isMicrophoneAccess = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Permission',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF4D4C4A),
              fontSize: 18,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
              height: 0.85,
              letterSpacing: -0.11,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 20.0, color: Color(0xFF4D4C4A)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 6, bottom: 6),
              decoration: BoxDecoration(
                color: Color(0xFFE9E9E9), // Grey background color
                borderRadius: BorderRadius.circular(8.0), // Border radius
              ),
              child: Column(children: [
                Container(
                  padding: const EdgeInsets.only(
                      left: 14, top: 6, right: 14, bottom: 4),
                  child: Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location services',
                            style: TextStyle(
                              color: Color(0xFF4D4C4A),
                              fontSize: 14,
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      SizedBox(
                        width: 25,
                        height: 15,
                        child: Transform.scale(
                          scale: 0.5,
                          child: Switch(
                            value: _isLocationServices,
                            onChanged: (value) {
                              setState(() {
                                _isLocationServices = value;
                              });
                            },
                            activeColor: Color(0xFF800000),
                            inactiveThumbColor: Color(0xFF4D4C4A),
                            inactiveTrackColor: Colors.grey[300],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Divider(),
                ),
                Container(
                  padding: const EdgeInsets.only(
                      left: 14, top: 6, right: 14, bottom: 4),
                  child: Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Upload contacts',
                            style: TextStyle(
                              color: Color(0xFF4D4C4A),
                              fontSize: 14,
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      SizedBox(
                        width: 25,
                        height: 15,
                        child: Transform.scale(
                          scale: 0.5,
                          child: Switch(
                            value: _isUploadContacts,
                            onChanged: (value) {
                              setState(() {
                                _isUploadContacts = value;
                              });
                            },
                            activeColor: Color(0xFF800000),
                            inactiveThumbColor: Color(0xFF4D4C4A),
                            inactiveTrackColor: Colors.grey[300],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Divider(),
                ),
                Container(
                  padding: const EdgeInsets.only(
                      left: 14, top: 6, right: 14, bottom: 4),
                  child: Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Camera access',
                            style: TextStyle(
                              color: Color(0xFF4D4C4A),
                              fontSize: 14,
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      SizedBox(
                        width: 25,
                        height: 15,
                        child: Transform.scale(
                          scale: 0.5,
                          child: Switch(
                            value: _isCameraAccess,
                            onChanged: (value) {
                              setState(() {
                                _isCameraAccess = value;
                              });
                            },
                            activeColor: Color(0xFF800000),
                            inactiveThumbColor: Color(0xFF4D4C4A),
                            inactiveTrackColor: Colors.grey[300],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Divider(),
                ),
                Container(
                  padding: const EdgeInsets.only(
                      left: 14, top: 6, right: 14, bottom: 4),
                  child: Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Microphone access',
                            style: TextStyle(
                              color: Color(0xFF4D4C4A),
                              fontSize: 14,
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      SizedBox(
                        width: 25,
                        height: 15,
                        child: Transform.scale(
                          scale: 0.5,
                          child: Switch(
                            value: _isMicrophoneAccess,
                            onChanged: (value) {
                              setState(() {
                                _isMicrophoneAccess = value;
                              });
                            },
                            activeColor: Color(0xFF800000),
                            inactiveThumbColor: Color(0xFF4D4C4A),
                            inactiveTrackColor: Colors.grey[300],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
