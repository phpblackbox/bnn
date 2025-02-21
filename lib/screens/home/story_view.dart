import 'package:bnn/providers/story_view_provider.dart';
import 'package:bnn/screens/chat/room.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cube_transition_plus/cube_transition_plus.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_supabase_chat_core/flutter_supabase_chat_core.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoryView extends StatefulWidget {
  final String id;

  const StoryView({super.key, required this.id});

  @override
  _StoryViewState createState() => _StoryViewState();
}

class _StoryViewState extends State<StoryView> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController _msgController = TextEditingController();

  final PageController _pageController = PageController();
  Timer? _timer;
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
    initialData();
  }

  Future<void> initialData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final storyViewProvider =
          Provider.of<StoryViewProvider>(context, listen: false);
      await storyViewProvider.getStoriesByUserId(widget.id);
      _startAutoSlide(storyViewProvider);
    });
  }

  void _startAutoSlide(StoryViewProvider storyViewProvider) {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (storyViewProvider.currentStoryIndex <
          storyViewProvider.story["img_urls"].length - 1) {
        storyViewProvider.currentStoryIndex++;
      } else {
        storyViewProvider.currentStoryIndex = 0;
      }

      _pageController.animateToPage(
        storyViewProvider.currentStoryIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _stopAutoSlide() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
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
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final storyViewProvider = Provider.of<StoryViewProvider>(context);
    return Scaffold(
      body: Stack(
        children: [
          storyViewProvider.loading
              ? Center(child: CircularProgressIndicator())
              : GestureDetector(
                  onHorizontalDragEnd: (details) {
                    if (details.velocity.pixelsPerSecond.dx > 0) {
                      storyViewProvider.previousStory();
                      _pageController.jumpToPage(0);
                    } else if (details.velocity.pixelsPerSecond.dx < 0) {
                      storyViewProvider.nextStory();
                      _pageController.jumpToPage(0);
                    }
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: CubePageView.builder(
                          itemCount: storyViewProvider.data.length,
                          onPageChanged: (i) {
                            storyViewProvider.currentStoryIndex = i;
                            storyViewProvider.story = storyViewProvider
                                .data[storyViewProvider.currentStoryIndex];
                            storyViewProvider.currentStoryIndex = 0;
                            _stopAutoSlide();
                            _startAutoSlide(storyViewProvider);
                          },
                          itemBuilder: (context, index, notifier) {
                            final tempStory = storyViewProvider.data[index];
                            return CubeWidget(
                              index: index,
                              pageNotifier: notifier,
                              child: PageView.builder(
                                controller: _pageController,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: tempStory["img_urls"].length,
                                onPageChanged: (i) {
                                  storyViewProvider.currentStoryIndex = i;
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
          storyViewProvider.loading
              ? Container()
              : Positioned(
                  top: 40.0,
                  left: 10,
                  right: 10,
                  child: Column(children: [
                    SizedBox(
                      height: 5.0,
                      child: Row(
                        children: List.generate(
                            storyViewProvider.story["img_urls"].length,
                            (index) {
                          return Expanded(
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 1.5),
                              decoration: BoxDecoration(
                                color:
                                    index == storyViewProvider.currentStoryIndex
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
                              storyViewProvider.story["profiles"]["avatar"],
                              fit: BoxFit.fill,
                              width: 42,
                              height: 42,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          storyViewProvider.story["profiles"]["username"],
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
                          storyViewProvider.story["timeDiff"],
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
          storyViewProvider.loading
              ? Container()
              : Positioned(
                  bottom: 40.0,
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
                        onPressed: () async {
                          final meId = supabase.auth.currentUser!.id;
                          if (storyViewProvider.story['author_id'] == meId) {
                            CustomToast.showToastWarningTop(
                                context, "You can't send message yourself");
                            return;
                          }

                          types.User otherUser = types.User(
                            id: storyViewProvider.story['author_id'],
                            firstName: storyViewProvider.story['profiles']
                                ['first_name'],
                            lastName: storyViewProvider.story['profiles']
                                ['last_name'],
                            imageUrl: storyViewProvider.story['profiles']
                                ['avatar'],
                          );

                          final navigator = Navigator.of(context);
                          final temp = await SupabaseChatCore.instance
                              .createRoom(otherUser);

                          var room = temp.copyWith(
                              imageUrl: storyViewProvider.story['profiles']
                                  ['avatar'],
                              name:
                                  "${storyViewProvider.story['profiles']['first_name']} ${storyViewProvider.story['profiles']['last_name']}");

                          final message = types.PartialText(
                              text: _msgController.text,
                              metadata: {
                                'image_url': storyViewProvider.story["img_urls"]
                                    [storyViewProvider.currentStoryIndex]
                              });

                          await SupabaseChatCore.instance
                              .sendMessage(message, room.id);

                          _msgController.clear();

                          await supabase.from('notifications').insert({
                            'actor_id': meId,
                            'user_id': storyViewProvider.story['author_id'],
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
