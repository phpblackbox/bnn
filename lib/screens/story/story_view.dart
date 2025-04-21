import 'dart:typed_data';

import 'package:bnn/providers/story_view_provider.dart';
import 'package:bnn/screens/chat/room.dart';
import 'package:bnn/utils/constants.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui' as ui;
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

class _StoryViewState extends State<StoryView>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController _msgController = TextEditingController();
  final FocusNode _msgFocusNode = FocusNode();
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

  late StoryViewProvider storyViewProvider;
  late PageController _storyPageController;
  late Map<int, PageController> _imagePageControllers;
  bool _isTransitioning = false;
  double _dragDistance = 0;
  late AnimationController _slideController;
  late Animation<Offset> _slideLeftAnimation;
  late Animation<Offset> _slideRightAnimation;
  late Animation<double> _fadeAnimation;
  bool _isSlidingLeft = true;
  bool _isInitialContentLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    storyViewProvider = Provider.of<StoryViewProvider>(context, listen: false);
    _storyPageController = PageController();
    _imagePageControllers = {};
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideLeftAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
    _slideRightAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
    _msgFocusNode.addListener(_onMsgFocusChange);
    _initializeStory();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      if (storyViewProvider.controller != null &&
          storyViewProvider.controller!.value.isInitialized &&
          storyViewProvider.controller!.value.isPlaying) {
        storyViewProvider.controller!.pause();
      }
    }
    super.didChangeAppLifecycleState(state);
  }

  void _onMsgFocusChange() async {
    if (_msgFocusNode.hasFocus) {
      _slideController.forward();
      final currentMediaUrl = storyViewProvider.currentStory?["media_urls"][storyViewProvider.currentImageIndex];
      if (currentMediaUrl != null && _isVideo(currentMediaUrl) && storyViewProvider.controller != null) {
        if (storyViewProvider.controller!.value.isPlaying) {
          await storyViewProvider.controller!.pause();
        }
      }
    }
  }

  void _initializeStory() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await storyViewProvider.initialize(widget.id);
      if (mounted) {
        setState(() {
          _isInitialContentLoaded = true;
        });
        _slideController.forward();
        print("INITIALIZE: Triggered slideController.forward()");
      }
    });
  }

  void _handleSwipe() async {
    if (_isTransitioning) return;
    _isTransitioning = true;
    _isSlidingLeft = true;
    _slideController.forward(from: 0.0);
    FocusScope.of(context).unfocus();
    final currentMediaUrl = storyViewProvider.currentStory!["media_urls"][storyViewProvider.currentImageIndex];
    if (_isVideo(currentMediaUrl) && storyViewProvider.controller != null) {
      await storyViewProvider.controller!.pause();
    }
    await storyViewProvider.nextStory();
    _msgController.clear();
    final newIndex = storyViewProvider.currentStoryIndex;
    if (_imagePageControllers.containsKey(newIndex)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_imagePageControllers[newIndex]?.hasClients ?? false) {
          _imagePageControllers[newIndex]!.jumpToPage(0);
        }
      });
    }
    _isTransitioning = false;
  }

  void _handlePreviousSwipe() async {
    if (_isTransitioning) return;
    _isTransitioning = true;
    _isSlidingLeft = false;
    _slideController.forward(from: 0.0);
    FocusScope.of(context).unfocus();
    final currentMediaUrl = storyViewProvider.currentStory!["media_urls"][storyViewProvider.currentImageIndex];
    if (_isVideo(currentMediaUrl) && storyViewProvider.controller != null) {
      await storyViewProvider.controller!.pause();
    }
    await storyViewProvider.previousStory();
    _msgController.clear();
    final newIndex = storyViewProvider.currentStoryIndex;
    if (_imagePageControllers.containsKey(newIndex)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_imagePageControllers[newIndex]?.hasClients ?? false) {
          _imagePageControllers[newIndex]!.jumpToPage(0);
        }
      });
    }
    _isTransitioning = false;
  }

  @override
  Widget build(BuildContext context) {
    final storyViewProvider = Provider.of<StoryViewProvider>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: storyViewProvider.loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GestureDetector(
                  onHorizontalDragUpdate: (DragUpdateDetails details) {
                    _dragDistance +=
                        details.delta.dx; // Track horizontal distance
                  },
                  onHorizontalDragEnd: (DragEndDetails details) {
                    if (details.primaryVelocity!.abs() > 150 ||
                        _dragDistance.abs() > 50) {
                      if (details.primaryVelocity! < 0 || _dragDistance < -50) {
                        _handleSwipe();
                      } else if (details.primaryVelocity! > 0 ||
                          _dragDistance > 50) {
                        _handlePreviousSwipe();
                      }
                    }
                    _dragDistance = 0;
                  },
                  behavior: HitTestBehavior.opaque,
                  
                  child: SlideTransition(
                    position: _isSlidingLeft
                        ? _slideLeftAnimation
                        : _slideRightAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _isInitialContentLoaded
                          ? (storyViewProvider.currentStory == null)
                              ? const SizedBox.shrink()
                              : Builder(builder: (context) {
                                  final index = storyViewProvider.currentStoryIndex;
                                  if (!_imagePageControllers.containsKey(index)) {
                                    _imagePageControllers[index] = PageController(
                                        initialPage: storyViewProvider.currentImageIndex);
                                  }
                                  final controller = _imagePageControllers[index];
                                  if (controller == null) {
                                    return Center(
                                        child: Text("Error loading story content",
                                            style: TextStyle(color: Colors.red)));
                                  }
                                  return Stack(
                                    children: [
                                      GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTapUp: (details) async {
                                          final box = context.findRenderObject() as RenderBox;
                                          final localPosition = box.globalToLocal(details.globalPosition);
                                          final width = box.size.width;
                                          final height = box.size.height;
                                          final leftThreshold = width * 0.25;
                                          final rightThreshold = width * 0.75;
                                          final topThreshold = height * 0.25;
                                          final bottomThreshold = height * 0.75;
                                          final mediaCount = storyViewProvider.currentStory["media_urls"].length;
                                          final currentIndex = storyViewProvider.currentImageIndex;

                                          if (localPosition.dx < leftThreshold && 
                                              localPosition.dy > topThreshold && 
                                              localPosition.dy < bottomThreshold) {
                                            // Tap left: previous media or previous story
                                            if (currentIndex > 0) {
                                              storyViewProvider.currentImageIndex = currentIndex - 1;
                                              controller.jumpToPage(storyViewProvider.currentImageIndex);
                                              final mediaUrl = storyViewProvider.currentStory["media_urls"][storyViewProvider.currentImageIndex];
                                              if (_isVideo(mediaUrl)) {
                                                await storyViewProvider.loadVideo(mediaUrl);
                                              } else {
                                                if (storyViewProvider.controller != null) {
                                                  await storyViewProvider.controller!.dispose();
                                                  storyViewProvider.controller = null;
                                                  storyViewProvider.initializeVideoPlayerFuture = null;
                                                }
                                              }
                                            } else {
                                              // At first media, go to previous story
                                              await storyViewProvider.previousStory();
                                              final newIndex = storyViewProvider.currentStoryIndex;
                                              if (_imagePageControllers.containsKey(newIndex)) {
                                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                                  if (_imagePageControllers[newIndex]?.hasClients ?? false) {
                                                    _imagePageControllers[newIndex]!.jumpToPage(0);
                                                  }
                                                });
                                              }
                                            }
                                          } else if (localPosition.dx > rightThreshold && 
                                                   localPosition.dy > topThreshold && 
                                                   localPosition.dy < bottomThreshold) {
                                            // Tap right: next media or next story
                                            if (currentIndex < mediaCount - 1) {
                                              storyViewProvider.currentImageIndex = currentIndex + 1;
                                              controller.jumpToPage(storyViewProvider.currentImageIndex);
                                              final mediaUrl = storyViewProvider.currentStory["media_urls"][storyViewProvider.currentImageIndex];
                                              if (_isVideo(mediaUrl)) {
                                                await storyViewProvider.loadVideo(mediaUrl);
                                              } else {
                                                if (storyViewProvider.controller != null) {
                                                  await storyViewProvider.controller!.dispose();
                                                  storyViewProvider.controller = null;
                                                  storyViewProvider.initializeVideoPlayerFuture = null;
                                                }
                                              }
                                            } else {
                                              // At last media, go to next story
                                              await storyViewProvider.nextStory();
                                              final newIndex = storyViewProvider.currentStoryIndex;
                                              if (_imagePageControllers.containsKey(newIndex)) {
                                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                                  if (_imagePageControllers[newIndex]?.hasClients ?? false) {
                                                    _imagePageControllers[newIndex]!.jumpToPage(0);
                                                  }
                                                });
                                              }
                                            }
                                          }
                                        },
                                        child: PageView.builder(
                                          controller: controller,
                                          itemCount: storyViewProvider.currentStory["media_urls"].length,
                                          physics: NeverScrollableScrollPhysics(),
                                          onPageChanged: null, // Disable onPageChanged, handled by tap
                                          itemBuilder: (context, mediaIndex) {
                                            final mediaUrl = storyViewProvider.currentStory["media_urls"][mediaIndex];
                                            if (_isVideo(mediaUrl)) {
                                              return FutureBuilder<void>(
                                                future: storyViewProvider.initializeVideoPlayerFuture,
                                                builder: (context, snapshot) {
                                                  if (snapshot.connectionState == ConnectionState.done) {
                                                    if (storyViewProvider.controller != null &&
                                                        storyViewProvider.controller!.value.isInitialized) {
                                                      return Center(
                                                        child: AspectRatio(
                                                          aspectRatio: storyViewProvider.controller!.value.aspectRatio,
                                                          child: VideoPlayer(storyViewProvider.controller!),
                                                        ),
                                                      );
                                                    } else {
                                                      return const Center(
                                                        child: Icon(Icons.error_outline, color: Colors.red, size: 50),
                                                      );
                                                    }
                                                  } else if (snapshot.hasError) {
                                                    return const Center(
                                                      child: Icon(Icons.error, color: Colors.red, size: 50),
                                                    );
                                                  } else {
                                                    return const Center(
                                                      child: CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2,
                                                      ),
                                                    );
                                                  }
                                                },
                                              );
                                            } else {
                                              return Image.network(
                                                mediaUrl,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                })
                          : const SizedBox.shrink(),
                    ),
                  ),
                ),
                Positioned(
                  top: 40.0,
                  left: 10,
                  right: 10,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 5.0,
                        child: Row(
                          children: List.generate(
                              storyViewProvider
                                  .currentStory!["media_urls"].length, (index) {
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
                              child: Image.network(
                                storyViewProvider.currentStory["profiles"]
                                    ["avatar"],
                                fit: BoxFit.fill,
                                width: 42,
                                height: 42,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            storyViewProvider.currentStory["profiles"]
                                ["username"],
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
                            storyViewProvider.currentStory["timeDiff"],
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
                            onTap: () async {
                              // Pause video and stop audio before closing
                              if (storyViewProvider.controller != null &&
                                  storyViewProvider.controller!.value.isInitialized &&
                                  storyViewProvider.controller!.value.isPlaying) {
                                await storyViewProvider.controller!.pause();
                              }
                              Navigator.pop(context);
                            },
                            child: ImageIcon(
                              AssetImage('assets/images/icons/close.png'),
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 8),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 40.0,
                  left: 10,
                  right: 10,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _msgController,
                          focusNode: _msgFocusNode,
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
                          if (storyViewProvider.currentStory['author_id'] ==
                              meId) {
                            CustomToast.showToastWarningTop(
                                context, "You can't send message yourself");
                            return;
                          }
                          types.User otherUser = types.User(
                            id: storyViewProvider.currentStory['author_id'],
                            firstName: storyViewProvider
                                .currentStory['profiles']['first_name'],
                            lastName: storyViewProvider.currentStory['profiles']
                                ['last_name'],
                            imageUrl: storyViewProvider.currentStory['profiles']
                                ['avatar'],
                          );
                          final navigator = Navigator.of(context);
                          final temp = await SupabaseChatCore.instance
                              .createRoom(otherUser);
                          var room = temp.copyWith(
                              imageUrl: storyViewProvider
                                  .currentStory['profiles']['avatar'],
                              name:
                                  "${storyViewProvider.currentStory['profiles']['first_name']} ${storyViewProvider.currentStory['profiles']['last_name']}");
                          final imageUrl =
                              _isVideo(storyViewProvider.currentStory["media_urls"][storyViewProvider.currentImageIndex])
                                  ? await capturePausedFrame()
                                  : storyViewProvider.currentStory["media_urls"][storyViewProvider.currentImageIndex];
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
                            'user_id':
                                storyViewProvider.currentStory['author_id'],
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
                            'assets/images/icons/send.png',
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
    if (storyViewProvider.controller!.value.isPlaying) {
      await storyViewProvider.controller!.pause();
    }

    final repaintBoundaryKey = GlobalKey();

    final videoWidget = RepaintBoundary(
      key: repaintBoundaryKey,
      child: Container(
        width: 300,
        height: 300 / storyViewProvider.controller!.value.aspectRatio,
        child: AspectRatio(
          aspectRatio: storyViewProvider.controller!.value.aspectRatio,
          child: VideoPlayer(storyViewProvider.controller!),
        ),
      ),
    );

    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: -10000,
        child: videoWidget,
      ),
    );

    try {
      overlay.insert(overlayEntry);

      await Future.delayed(Duration(milliseconds: 100));

      final boundary = repaintBoundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return "";

      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

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
    } finally {
      overlayEntry.remove();
    }

    return "";
  }

  bool _isVideo(String url) {
    final videoExtensions = ['.mp4', '.mov', '.avi', '.wmv', '.flv', '.mkv'];
    return videoExtensions.any((ext) => url.toLowerCase().endsWith(ext));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _msgFocusNode.dispose();
    _storyPageController.dispose();
    _slideController.dispose();
    for (var controller in _imagePageControllers.values) {
      controller.dispose();
    }
    // Dispose video controller if it exists and is playing
    if (storyViewProvider.controller != null &&
        storyViewProvider.controller!.value.isInitialized) {
      storyViewProvider.controller!.pause();
      storyViewProvider.controller!.dispose();
    }
    super.dispose();
  }
}
