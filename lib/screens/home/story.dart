import 'dart:typed_data';

import 'package:bnn/main.dart';
import 'package:bnn/screens/chat/room.dart';
import 'package:bnn/utils/constants.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cube_transition_plus/cube_transition_plus.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_supabase_chat_core/flutter_supabase_chat_core.dart';
import 'package:http/http.dart' as http;

class Story extends StatefulWidget {
  final String id;

  const Story({super.key, required this.id});

  @override
  _StoryState createState() => _StoryState();
}

class _StoryState extends State<Story> {
  final TextEditingController _msgController = TextEditingController();

  List<dynamic> data = [];
  dynamic story = {
    "img_urls": [],
    "id": 0,
    "username": "",
    "avatar": "",
    "authour_id": "",
    "created_at": '',
    "comments": "",
  };

  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _timer;

  int currentStory = 0;

  final List<String> emojis = [
    '😫',
    '🤥',
    '😐',
    '😘',
    '🔥',
    '🤬',
    '😍',
    '🥳',
    '😐',
    '🤐',
    '😱'
  ];

  @override
  void initState() {
    super.initState();
    fetchstory();
  }

  Future<void> fetchstory() async {
    try {
      data = await supabase
          .from('stories')
          .select('*, profiles(avatar, username, first_name, last_name)')
          .eq('author_id', widget.id)
          .eq('is_published', true)
          .order('id', ascending: false);

      if (data.isNotEmpty) {
        for (int i = 0; i < data.length; i++) {
          final nowString = await supabase.rpc('get_server_time');
          DateTime now = DateTime.parse(nowString);
          DateTime createdAt = DateTime.parse(data[i]["created_at"]);
          Duration difference = now.difference(createdAt);
          data[i]['timeDiff'] = Constants().formatDuration(difference);
        }

        setState(() {
          story = data[currentStory];
        });
        _startAutoSlide();
      }
    } catch (e) {
      print('Caught error: $e');
      if (e.toString().contains("JWT expired")) {
        await supabase.auth.signOut();
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_currentIndex < story["img_urls"].length - 1) {
        setState(() {
          _currentIndex++;
        });
      } else {
        setState(() {
          _currentIndex = 0;
        });
      }

      _pageController.animateToPage(
        _currentIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _stopAutoSlide() {
    _timer?.cancel(); // Stop the timer
    _timer = null; // Clear the timer reference
  }

  void _resumeAutoSlide() {
    if (_timer == null) {
      // Only start if it's not already running
      _startAutoSlide();
    }
  }

  void _nextStory() {
    print("nexsotry");
    if (data.isNotEmpty) {
      setState(() {
        currentStory = (currentStory + 1) % data.length;
        story = data[currentStory];
        _currentIndex = 0; // Reset index for new story
        _pageController.jumpToPage(0); // Reset page view to first image
      });
    }
  }

  void _previousStory() {
    print("previoussotry");

    if (data.isNotEmpty) {
      setState(() {
        currentStory = (currentStory - 1 + data.length) % data.length;
        story = data[currentStory];
        _currentIndex = 0; // Reset index for new story
        _pageController.jumpToPage(0); // Reset page view to first image
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when disposing
    _pageController.dispose();
    super.dispose();
  }

  void _showEmojiModal(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return Center(
            child: Material(
          color: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10), // Add some spacing
                GridView.builder(
                  physics: NeverScrollableScrollPhysics(), // Disable scrolling
                  shrinkWrap:
                      true, // Allow the grid to take only the needed space
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    childAspectRatio: 1,
                  ),
                  itemCount: emojis.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        _onEmojiSelected(context, emojis[index]);
                      },
                      child: Center(
                        child: Text(
                          emojis[index],
                          style: TextStyle(fontSize: 32),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ));
      },
    );
  }

  void _onEmojiSelected(BuildContext context, String emoji) {
    // Close the modal
    Navigator.pop(context);

    // Show a snackbar or handle the event as needed
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You selected: $emoji')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          data.isEmpty
              ? Center(child: CircularProgressIndicator())
              : GestureDetector(
                  onHorizontalDragEnd: (details) {
                    if (details.velocity.pixelsPerSecond.dx > 0) {
                      // User swiped right, go to previous story
                      _previousStory();
                    } else if (details.velocity.pixelsPerSecond.dx < 0) {
                      // User swiped left, go to next story
                      _nextStory();
                    }
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: CubePageView.builder(
                          itemCount: data.length,
                          onPageChanged: (i) {
                            setState(() {
                              currentStory = i;
                              story = data[currentStory];
                              _currentIndex = 0;
                              _stopAutoSlide();
                              _startAutoSlide();
                            });
                          },
                          itemBuilder: (context, index, notifier) {
                            final tempStory = data[index];
                            return CubeWidget(
                              index: index,
                              pageNotifier: notifier,
                              child: PageView.builder(
                                controller: _pageController,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: tempStory["img_urls"].length,
                                onPageChanged: (i) {
                                  setState(() {
                                    _currentIndex = i;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  return Image.network(
                                    tempStory["img_urls"][index],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
          if (story['profiles'] != null)
            Positioned(
              top: 20.0,
              left: 10,
              right: 10,
              child: Column(children: [
                SizedBox(
                  height: 5.0,
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
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(
                          color: Colors.white,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(21),
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
                      story["timeDiff"],
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
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(10),
                    backgroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final meId = supabase.auth.currentUser!.id;
                    if (story['author_id'] == meId) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("You can't send message to you"),
                      ));
                      return;
                    }

                    types.User otherUser = types.User(
                      id: story['author_id'],
                      firstName: story['profiles']['first_name'],
                      lastName: story['profiles']['last_name'],
                      imageUrl: story['profiles']['avatar'],
                    );

                    final navigator = Navigator.of(context);
                    final temp =
                        await SupabaseChatCore.instance.createRoom(otherUser);

                    var room = temp.copyWith(
                        imageUrl: story['profiles']['avatar'],
                        name:
                            "${story['profiles']['first_name']} ${story['profiles']['last_name']}");

                    final message = types.PartialText(
                        text: _msgController.text,
                        metadata: {
                          'image_url': story["img_urls"][_currentIndex]
                        });

                    await SupabaseChatCore.instance
                        .sendMessage(message, room.id);

                    _msgController.clear();

                    await supabase.from('notifications').insert({
                      'actor_id': meId,
                      'user_id': story['author_id'],
                      'action_type': 'comment story',
                      'content': _msgController.text,
                    });

                    await navigator.push(
                      MaterialPageRoute(
                        builder: (context) => RoomPage(room: room),
                      ),
                    );
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
                    _showEmojiModal(context);
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
            ),
          ),
        ],
      ),
    );
  }
}
