import 'package:flutter/material.dart';

class MediaPreferences extends StatefulWidget {
  const MediaPreferences({super.key});

  @override
  State<MediaPreferences> createState() => _MediaPreferencesState();
}

class _MediaPreferencesState extends State<MediaPreferences> {
  final dynamic _selectedAutoPlay = [
    {'id': 1, 'content': 'On Wi-fi and mobile data', 'status': true},
    {'id': 2, 'content': 'On Wi-Fi only', 'status': false},
    {'id': 3, 'content': 'Never autoplay videos', 'status': false},
  ];

  final dynamic _selectedPhotoQuality = [
    {'id': 1, 'content': 'High', 'status': true},
    {'id': 2, 'content': 'Medium', 'status': false},
    {'id': 3, 'content': 'Low', 'status': false},
  ];

  final dynamic _selectedVideoQuality = [
    {'id': 1, 'content': 'Optimized quality', 'status': true},
    {'id': 2, 'content': 'Lowest-quality video', 'status': false},
  ];

  void _toggleAutoPlay(int index) {
    setState(() {
      // Set all items to false and only select the tapped item
      for (var item in _selectedAutoPlay) {
        item['status'] = false;
      }
      _selectedAutoPlay[index]['status'] = true;
    });
  }

  void _togglePhotoQuality(int index) {
    setState(() {
      for (var item in _selectedPhotoQuality) {
        item['status'] = false;
      }
      _selectedPhotoQuality[index]['status'] = true;
    });
  }

  void _toggleVideoQuality(int index) {
    setState(() {
      for (var item in _selectedVideoQuality) {
        item['status'] = false;
      }
      _selectedVideoQuality[index]['status'] = true;
    });
  }

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
                  'Media Preferences',
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
            Text(
              'AUTOPLAY OPTIONS',
              style: TextStyle(
                color: Color(0xFF4D4C4A),
                fontSize: 11,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w300,
              ),
            ),
            Container(
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: Color(0xFFE9E9E9),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _selectedAutoPlay.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _toggleAutoPlay(index),
                    child: Column(children: [
                      Container(
                        padding: const EdgeInsets.only(left: 14, right: 14),
                        child: Row(
                          children: [
                            Text(
                              _selectedAutoPlay[index]['content'],
                              style: TextStyle(
                                color: Color(0xFF4D4C4A),
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Spacer(),
                            Icon(
                              _selectedAutoPlay[index]['status']
                                  ? Icons.check
                                  : null,
                              color: _selectedAutoPlay[index]['status']
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ],
                        ),
                      ),
                      if (index != _selectedAutoPlay.length - 1) Divider(),
                    ]),
                  );
                },
              ),
            ),
            Text(
              'Playing videos uses more data than displaying photos, so choose when videos autoplay here.',
              style: TextStyle(
                color: Color(0x724D4C4A),
                fontSize: 12,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Photo quality',
              style: TextStyle(
                color: Color(0xFF4D4C4A),
                fontSize: 10,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w300,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFE9E9E9), // Grey background color
                borderRadius: BorderRadius.circular(8.0), // Border radius
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _selectedPhotoQuality.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _togglePhotoQuality(index),
                    child: Column(children: [
                      Container(
                        padding: const EdgeInsets.only(left: 14, right: 14),
                        child: Row(
                          children: [
                            Text(
                              _selectedPhotoQuality[index]['content'],
                              style: TextStyle(
                                color: Color(0xFF4D4C4A),
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Spacer(),
                            Icon(
                              _selectedPhotoQuality[index]['status']
                                  ? Icons.check
                                  : null,
                              color: _selectedPhotoQuality[index]['status']
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ],
                        ),
                      ),
                      if (index != _selectedPhotoQuality.length - 1) Divider(),
                    ]),
                  );
                },
              ),
            ),
            Text(
              'Selecting low quality uses less data and helps BNN load faster',
              style: TextStyle(
                color: Color(0x724D4C4A),
                fontSize: 12,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Video quality',
              style: TextStyle(
                color: Color(0xFF4D4C4A),
                fontSize: 10,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w300,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFE9E9E9), // Grey background color
                borderRadius: BorderRadius.circular(8.0), // Border radius
              ),
              child: ListView.builder(
                shrinkWrap: true,
                // physics: NeverScrollableScrollPhysics(),
                itemCount: _selectedVideoQuality.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _toggleVideoQuality(index),
                    child: Column(children: [
                      Container(
                        padding: const EdgeInsets.only(left: 14, right: 14),
                        child: Row(
                          children: [
                            Text(
                              _selectedVideoQuality[index]['content'],
                              style: TextStyle(
                                color: Color(0xFF4D4C4A),
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Spacer(),
                            Icon(
                              _selectedVideoQuality[index]['status']
                                  ? Icons.check
                                  : null,
                              color: _selectedVideoQuality[index]['status']
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ],
                        ),
                      ),
                      Divider()
                    ]),
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
