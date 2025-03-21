import 'dart:typed_data';

import 'package:bnn/providers/story_view_provider.dart';
import 'package:bnn/screens/chat/room.dart';
import 'package:bnn/utils/constants.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:cube_transition_plus/cube_transition_plus.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_supabase_chat_core/flutter_supabase_chat_core.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';

class StoryView extends StatefulWidget {
  final int id;

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

  StoryViewProvider? _storyViewProvider;
  late FocusNode _focusNode;

  final GlobalKey _videoKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    initialData();
    _focusNode = FocusNode();
    _focusNode.addListener(() async {
      if (_focusNode.hasFocus) {
        await _storyViewProvider!.controller!.pause();
      } else {
        print("TextField lost focus");
      }
    });
  }

  Future<void> initialData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final storyViewProvider =
          Provider.of<StoryViewProvider>(context, listen: false);
      await storyViewProvider.initialize(widget.id);
      _startAutoSlide(storyViewProvider);
    });
  }

  void _startAutoSlide(StoryViewProvider storyViewProvider) {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (storyViewProvider.currentImageIndex <
          storyViewProvider.story["img_urls"].length - 1) {
        storyViewProvider.currentImageIndex++;
      } else {
        storyViewProvider.currentImageIndex = 0;
      }

      _pageController.animateToPage(
        storyViewProvider.currentImageIndex,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _stopAutoSlide() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _storyViewProvider = Provider.of<StoryViewProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _storyViewProvider?.close();
    _focusNode.dispose();
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
                SizedBox(height: 10),
                GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
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

  Future<String> capturePausedFrame() async {
    if (_storyViewProvider!.controller!.value.isPlaying) {
      await _storyViewProvider!.controller!.pause();
    }

    RenderRepaintBoundary boundary =
        _videoKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    ui.Image image = await boundary.toImage(pixelRatio: 2.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      String randomNumStr = Constants().generateRandomNumberString(8);
      final filename = '$randomNumStr.png';
      List<int> bytes = byteData.buffer.asUint8List();
      Uint8List uint8ByteData = Uint8List.fromList(bytes);
      await supabase.storage.from('story').uploadBinary(
            filename,
            uint8ByteData,
          );

      return supabase.storage.from('story').getPublicUrl(filename);
    }

    return "";
  }

  @override
  Widget build(BuildContext context) {
    final storyViewProvider = Provider.of<StoryViewProvider>(context);
    return Scaffold(
      // backgroundColor: Colors.black,
      body: Stack(
        children: [
          storyViewProvider.loading
              ? Center(child: CircularProgressIndicator())
              : GestureDetector(
                  onTapDown: (details) {
                    double dx = details.globalPosition.dx;
                    double dy = details.globalPosition.dy;
                    double screenWidth = MediaQuery.of(context).size.width;
                    double screenHieght = MediaQuery.of(context).size.height;

                    if (dx < screenWidth / 4) {
                      FocusScope.of(context).unfocus();
                      if (storyViewProvider.story['type'] == 'image') {
                        storyViewProvider.prevImage();
                        _pageController.animateToPage(
                          storyViewProvider.currentImageIndex,
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        storyViewProvider.previousStory();
                      }
                    } else if (dx > 3 * screenWidth / 4) {
                      FocusScope.of(context).unfocus();
                      if (storyViewProvider.story['type'] == 'image') {
                        storyViewProvider.nextImage();
                        _pageController.animateToPage(
                          storyViewProvider.currentImageIndex,
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        storyViewProvider.nextStory();
                      }
                    } else if (storyViewProvider.story['type'] == 'video' &&
                        dy > screenHieght / 4 &&
                        dy < 3 * screenHieght / 4) {
                      if (storyViewProvider.controller!.value.isPlaying) {
                        storyViewProvider.controller!.pause();
                      } else {
                        storyViewProvider.controller!.play();
                      }
                    }
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: CubePageView.builder(
                          itemCount: storyViewProvider.stories.length,
                          onPageChanged: (i) async {
                            if (i > storyViewProvider.currentStoryIndex) {
                              FocusScope.of(context).unfocus();
                              await storyViewProvider.controller!.pause();
                              await storyViewProvider.nextStory();
                            } else if (i <
                                storyViewProvider.currentStoryIndex) {
                              FocusScope.of(context).unfocus();
                              await storyViewProvider.controller!.pause();
                              await storyViewProvider.previousStory();
                            }
                            storyViewProvider.currentImageIndex = 0;
                            _stopAutoSlide();
                            _startAutoSlide(storyViewProvider);
                          },
                          itemBuilder: (context, index, notifier) {
                            final tempStory = storyViewProvider.stories[index];
                            return CubeWidget(
                              index: index,
                              pageNotifier: notifier,
                              child: tempStory["type"] == "image"
                                  ? PageView.builder(
                                      controller: _pageController,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: tempStory["img_urls"].length,
                                      onPageChanged: (i) {
                                        storyViewProvider.currentImageIndex = i;
                                      },
                                      itemBuilder: (context, index) {
                                        return Image.network(
                                          tempStory["img_urls"][index],
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        );
                                      },
                                    )
                                  : FutureBuilder<void>(
                                      future: storyViewProvider
                                          .initializeVideoPlayerFuture,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.done) {
                                          return Center(
                                            child: RepaintBoundary(
                                              key: _videoKey,
                                              child: AspectRatio(
                                                aspectRatio: storyViewProvider
                                                    .controller!
                                                    .value
                                                    .aspectRatio,
                                                child: VideoPlayer(
                                                    storyViewProvider
                                                        .controller!),
                                              ),
                                            ),
                                          );
                                        } else {
                                          return Center(
                                              child:
                                                  CircularProgressIndicator());
                                        }
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
                  child: Column(
                    children: [
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
                                  color: index ==
                                          storyViewProvider.currentImageIndex
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.36),
                                  borderRadius: BorderRadius.circular(3.0),
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
                              color:
                                  Colors.white.withOpacity(0.8199999928474426),
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
                    ],
                  ),
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
                          focusNode: _focusNode,
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
                          final imageUrl =
                              storyViewProvider.story['type'] == "image"
                                  ? storyViewProvider.story["img_urls"]
                                      [storyViewProvider.currentImageIndex]
                                  : await capturePausedFrame();
                          final message = types.PartialText(
                              text: _msgController.text,
                              metadata: {
                                'image_url': imageUrl,
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
