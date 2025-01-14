import 'package:bnn/main.dart';
import 'package:bnn/utils/constants.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class Story extends StatefulWidget {
  final int id;

  const Story({Key? key, required this.id}) : super(key: key);

  @override
  _StoryState createState() => _StoryState();
}

class _StoryState extends State<Story> {
  final TextEditingController _msgController = TextEditingController();

  // final List<String> story["img_urls"] = [
  //   'assets/images/post/18.png',
  //   'assets/images/post/13.png',
  //   'assets/images/post/17.png',
  //   'assets/images/post/10.png',
  //   'assets/images/post/7.png',
  // ];

  dynamic story = {
    "img_urls": [],
    "id": 0,
    "username": "",
    "avatar": "",
    "authour_id": "",
    "created_at": '',
    "comments": "",
  };
  String timeDiff = "";

  PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchstory();
  }

  Future<void> fetchstory() async {
    if (supabase.auth.currentUser != null) {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        print('User is not logged in!');
        return;
      }

      try {
        // dynamic data = await supabase.rpc('get_story_by_id', params: {
        //   'story_id': widget.id,
        // });
        dynamic data = await supabase
            .from('stories')
            .select('*, profiles(username, avatar)') // Using select with join
            .eq('id', widget.id) // Filtering by story ID
            .eq('is_published', true) // Ensuring the story is published
            .single();

        if (data != null) {
          final nowString = await supabase.rpc('get_server_time');

          DateTime now = DateTime.parse(nowString);
          DateTime created_at = DateTime.parse(data["created_at"]);

          Duration difference = now.difference(created_at);
          print(difference);
          setState(() {
            story = data;
            timeDiff = Constants().formatDuration(difference);
          });
          _startAutoSlide();
        }
      } catch (e) {
        print('Caught error: $e');
      }
    }
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (_currentIndex < story["img_urls"].length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }

      _pageController.animateToPage(
        _currentIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when disposing
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Image Slideshow Background
          if (story["img_urls"].isEmpty)
            Center(child: CircularProgressIndicator()),

          if (story["img_urls"].isNotEmpty)
            PageView.builder(
              controller: _pageController,
              itemCount: story["img_urls"].length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex =
                      index; // Update current index when page changes
                });
              },
              itemBuilder: (context, index) {
                return Image.network(
                  story["img_urls"][index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                );
              },
            ),
          // Progress Indicator at the Top
          Positioned(
            top: 20.0, // Adjust as needed for positioning
            left: 10,
            right: 10,
            child: Column(children: [
              Container(
                height: 5.0, // Height of the progress bar
                child: Row(
                  children: List.generate(story["img_urls"].length, (index) {
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 1.5),
                        decoration: BoxDecoration(
                          color: index == _currentIndex
                              ? Colors.white
                              : Colors.white.withOpacity(0.36),
                          borderRadius: BorderRadius.circular(
                              3.0), // Set border radius here
                        ),
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(height: 8),
              if (story["img_urls"].isNotEmpty && timeDiff.isNotEmpty)
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors
                            .transparent, // Background color of the container
                        border: Border.all(
                          color: Colors.white, // Border color
                          width: 2.0, // Border thickness
                        ),
                        borderRadius: BorderRadius.circular(
                            21), // Optional: round the corners
                      ),
                      child: ClipOval(
                        // This will ensure the image is circular
                        child: Image.network(
                          story["profiles"]["avatar"],
                          fit: BoxFit.fill,
                          width: 42,
                          height: 42,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      story["profiles"]["username"],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.33,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      timeDiff,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8199999928474426),
                        fontSize: 12,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.07,
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: ImageIcon(
                        AssetImage('assets/images/icons/close.png'),
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
            ]),
          ),
          Positioned(
              bottom: 20.0,
              left: 10,
              right: 10,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      style: TextStyle(
                        fontSize: 10.0,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Your message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        filled: true,
                        fillColor: Color(0xFFE9E9E9),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 15.0),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(10),
                      backgroundColor: Colors.white,
                    ),
                    onPressed: () {
                      // Handle button press
                    },
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/icons/back.png',
                        color: Colors.black,
                        width: 20,
                        height: 20,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(10),
                      backgroundColor: Colors.white,
                    ),
                    onPressed: () {
                      // Handle button press
                    },
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/icons/heart3.png',
                        color: Color(0xFFFF0000),
                        width: 22,
                        height: 19,
                        fit: BoxFit.fill,
                      ),
                    ),
                  )
                ],
              )),
        ],
      ),
    );
  }
}
