import 'package:bnn/main.dart';
import 'package:bnn/screens/home/ReelComments.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class reel extends StatefulWidget {
  final int? reelId;
  const reel({super.key, this.reelId});

  @override
  _reelState createState() => _reelState();
}

class _reelState extends State<reel> with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;
  bool _loading = false;

  dynamic currentReel;
  dynamic nextReel;
  late dynamic userInfo;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  late int currentReelId;
  late int nextReelId;

  @override
  void initState() {
    super.initState();
    fetchInitData();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0, 1),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void fetchInitData() async {
    int randomReelId1;
    if (widget.reelId != null) {
      randomReelId1 = widget.reelId!;
    } else {
      randomReelId1 = await supabase.rpc('get_random_reel_id');
    }

    final temp = await fetchdata(randomReelId1);
    if (temp != null) {
      setState(() {
        currentReelId = randomReelId1;
        currentReel = temp;
      });
    }
    loadVideo(currentReel);

    int randomReelId2 = await supabase.rpc('get_random_reel_id');
    final temp2 = await fetchdata(randomReelId2);
    if (temp2 != null) {
      setState(() {
        nextReel = temp2;
        nextReelId = randomReelId2;
      });
    }
  }

  void nextStep() async {
    setState(() {
      currentReelId = nextReelId;
      currentReel = nextReel;
    });
    loadVideo(currentReel);

    final randomReelId = await supabase.rpc('get_random_reel_id');

    final temp = await fetchdata(randomReelId);
    if (temp != null) {
      setState(() {
        nextReel = temp;
        nextReelId = randomReelId;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void loadVideo(Map<String, dynamic> currentReel) {
    if (currentReel['video_url'] != null) {
      _controller?.dispose();
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(currentReel['video_url']),
      );

      _initializeVideoPlayerFuture = _controller!.initialize().then((_) {
        setState(() {
          _controller!.setLooping(true);
          _controller!.play();
        });
      }).catchError((error) {
        print("Error initializing video: $error");
      });
    } else {
      print("Video URL is not available");
    }
  }

  Future<Map<String, dynamic>?> fetchdata(reelId) async {
    final oneReel =
        await supabase.from('reels').select().eq("id", reelId).single();

    if (oneReel.isNotEmpty) {
      final temp = await supabase
          .from('profiles')
          .select()
          .eq('id', oneReel['author_id'])
          .single();

      final meId = supabase.auth.currentUser?.id;
      temp['is_friend'] = false;
      if (meId == oneReel['author_id']) {
        temp['is_friend'] = true;
      } else {
        print(meId);
        print(oneReel['author_id']);
        final is_friend = await supabase.rpc('is_friend',
            params: {'me_id': meId, 'user_id': oneReel['author_id']});

        temp['is_friend'] = is_friend;
      }
      oneReel['userInfo'] = temp;

      try {
        dynamic res =
            await supabase.rpc('get_count_reel_likes_by_reelid', params: {
                  'param_reel_id': reelId,
                }) ??
                0;

        oneReel["likes"] = res;

        res = await supabase.rpc('get_count_reel_bookmarks_by_reelid', params: {
          'param_reel_id': reelId,
        });

        oneReel["bookmarks"] = res;

        res = await supabase.rpc('get_count_reel_comments_by_reelid', params: {
          'param_reel_id': reelId,
        });

        oneReel["comments"] = res;
        oneReel["share"] = 2;

        return oneReel;
      } catch (e) {
        print('Caught error: $e');
        if (e.toString().contains("JWT expired")) {
          await supabase.auth.signOut();
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    }

    return null;
  }

  void _showCommentDetail(BuildContext context, int reelId) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return ReelCommands(reelId: reelId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Customize according to your theme

      body: Stack(
        children: <Widget>[
          if (_loading == false)
            GestureDetector(
              onVerticalDragEnd: (DragEndDetails details) {
                if (details.velocity.pixelsPerSecond.dy > 0 ||
                    details.velocity.pixelsPerSecond.dy < 0 ||
                    details.velocity.pixelsPerSecond.dx > 0) {
                  _animationController.forward().then((_) {
                    _animationController.reverse();
                    _controller!.pause();
                    nextStep();
                  });
                }
              },
              child: SlideTransition(
                position: _slideAnimation,
                child: FutureBuilder<void>(
                  future: _initializeVideoPlayerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return VideoPlayer(_controller!);
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ),
          Positioned(
            top: 15,
            left: 0,
            child: IconButton(
              icon: Icon(Icons.close, size: 20, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          if (currentReel != null)
            Positioned(
              bottom: 60,
              right: 12,
              child: Column(
                children: [
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final userId = supabase.auth.currentUser!.id;

                          final existingLikeResponse = await supabase
                              .from('reel_likes')
                              .select()
                              .eq('author_id', userId)
                              .eq('reel_id', currentReelId)
                              .maybeSingle();

                          if (existingLikeResponse != null) {
                            bool currentLikeStatus =
                                existingLikeResponse['is_like'];
                            await supabase
                                .from('reel_likes')
                                .update({
                                  'is_like': !currentLikeStatus,
                                })
                                .eq('author_id', userId)
                                .eq('reel_id', currentReelId);

                            setState(() {
                              if (currentLikeStatus) currentReel["likes"]--;
                              if (!currentLikeStatus) currentReel["likes"]++;
                            });
                          } else {
                            await supabase.from('reel_likes').upsert({
                              'author_id': userId,
                              'reel_id': currentReelId,
                              'is_like': true,
                            });

                            setState(() {
                              currentReel["likes"]++;
                            });
                          }

                          final noti = await supabase
                              .from('notifications')
                              .select()
                              .eq('actor_id', userId)
                              .eq('user_id', currentReel['author_id'])
                              .eq('action_type', 'like reel')
                              .eq('target_id', currentReel['id']);

                          if (userId != currentReel['author_id'] &&
                              noti.isEmpty) {
                            await supabase.from('notifications').upsert({
                              'actor_id': userId,
                              'user_id': currentReel['author_id'],
                              'action_type': 'like reel',
                              'target_id': currentReel['id'],
                            });
                          }
                        },
                        child: ImageIcon(
                          AssetImage('assets/images/icons/like.png'),
                          color: Colors.white,
                          size: 27,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        currentReel["likes"].toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _showCommentDetail(context, currentReelId);
                        },
                        child: ImageIcon(
                          AssetImage('assets/images/icons/comment2.png'),
                          color: Colors.white,
                          size: 27,
                        ),
                      ),
                      Text(
                        currentReel["comments"].toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final userId = supabase.auth.currentUser!.id;
                          print(userId);
                          final existingBookmarksResponse = await supabase
                              .from('reel_bookmarks')
                              .select()
                              .eq('author_id', userId)
                              .eq('reel_id', currentReelId)
                              .maybeSingle();

                          if (existingBookmarksResponse != null) {
                            bool currentBookmarksStatus =
                                existingBookmarksResponse['is_bookmark'];
                            await supabase
                                .from('reel_bookmarks')
                                .update({
                                  'is_bookmark': !currentBookmarksStatus,
                                })
                                .eq('author_id', userId)
                                .eq('reel_id', currentReelId);

                            setState(() {
                              if (currentBookmarksStatus) {
                                currentReel["bookmarks"]--;
                              }
                              if (!currentBookmarksStatus) {
                                currentReel["bookmarks"]++;
                              }
                            });
                          } else {
                            await supabase.from('reel_bookmarks').upsert({
                              'author_id': userId,
                              'reel_id': currentReelId,
                              'is_bookmark': true,
                            });

                            setState(() {
                              currentReel["bookmarks"]++;
                            });
                          }
                        },
                        child: ImageIcon(
                          AssetImage('assets/images/icons/bookmark2.png'),
                          color: Colors.white,
                          size: 27,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        currentReel["bookmarks"].toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: ImageIcon(
                          AssetImage('assets/images/icons/share.png'),
                          color: Colors.white,
                          size: 27,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        currentReel["share"].toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          if (currentReel != null && currentReel['userInfo'] != null)
            Positioned(
              bottom: 50.0,
              left: 10,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage:
                        NetworkImage(currentReel['userInfo']['avatar']),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '${currentReel['userInfo']['first_name']} ${currentReel['userInfo']['last_name']}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 16),
                  if (currentReel['userInfo']['is_friend'] == false)
                    GestureDetector(
                      onTap: () async {
                        final meId = supabase.auth.currentUser!.id;

                        await supabase.from('relationships').upsert({
                          'follower_id': meId,
                          'followed_id': currentReel['author_id'],
                          'status': 'following',
                        });

                        await supabase.from('notifications').insert({
                          'actor_id': meId,
                          'user_id': currentReel['author_id'],
                          'action_type': 'follow'
                        });

                        setState(() {
                          currentReel['userInfo']['is_friend'] = true;
                        });
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 3, horizontal: 8.0),
                        decoration: ShapeDecoration(
                          color: Colors.black.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Follow',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                              ),
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
    );
  }
}
