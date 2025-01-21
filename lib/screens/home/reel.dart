import 'package:bnn/main.dart';
import 'package:bnn/screens/home/ReelComments.dart';
import 'package:bnn/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class reel extends StatefulWidget {
  const reel({
    super.key,
    required this.reelId,
  });

  final int reelId;

  @override
  _reelState createState() => _reelState();
}

class _reelState extends State<reel> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool _loading = false;

  late dynamic currentReel;

  @override
  void initState() {
    super.initState();
    fetchDataAndInitialize();
  }

  Future<void> fetchDataAndInitialize() async {
    await fetchdata(widget.reelId);

    if (currentReel['video_url'] != null) {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(currentReel['video_url']),
      );

      _initializeVideoPlayerFuture = _controller.initialize().then((_) {
        setState(() {
          _controller.setLooping(true);
          _controller.play();
        });
      }).catchError((error) {
        print("Error initializing video: $error");
      });
    } else {
      print("Video URL is not available");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> fetchdata(reelId) async {
    if (supabase.auth.currentUser != null) {
      setState(() {
        _loading = true;
      });

      final oneReel =
          await supabase.from('reels').select().eq("id", reelId).single();

      if (oneReel.isNotEmpty) {
        try {
          dynamic res =
              await supabase.rpc('get_count_reel_likes_by_reelid', params: {
                    'param_reel_id': widget.reelId,
                  }) ??
                  0;

          oneReel["likes"] = res;

          res =
              await supabase.rpc('get_count_reel_bookmarks_by_reelid', params: {
            'param_reel_id': widget.reelId,
          });

          oneReel["bookmarks"] = res;

          res =
              await supabase.rpc('get_count_reel_comments_by_reelid', params: {
            'param_reel_id': widget.reelId,
          });

          oneReel["comments"] = res;
          oneReel["share"] = 2;

          setState(() {
            currentReel = oneReel;
            _loading = false;
          });
        } catch (e) {
          print('Caught error: $e');
          if (e.toString().contains("JWT expired")) {
            await supabase.auth.signOut();
            Navigator.pushReplacementNamed(context, '/login');
          }
        }
      }
    }

    setState(() {
      _loading = false;
    });
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
            FutureBuilder<void>(
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return VideoPlayer(_controller);
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
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
          if (_loading == false)
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
                              .eq('reel_id', widget.reelId)
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
                                .eq('reel_id', widget.reelId);

                            setState(() {
                              if (currentLikeStatus) currentReel["likes"]--;
                              if (!currentLikeStatus) currentReel["likes"]++;
                            });
                          } else {
                            await supabase.from('reel_likes').upsert({
                              'author_id': userId,
                              'reel_id': widget.reelId,
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
                          _showCommentDetail(context, widget.reelId);
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
                              .eq('reel_id', widget.reelId)
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
                                .eq('reel_id', widget.reelId);

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
                              'reel_id': widget.reelId,
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
        ],
      ),
    );
  }
}
