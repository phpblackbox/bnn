import 'package:bnn/screens/reel/reel_comments.dart';
import 'package:bnn/screens/reel/reel_video_player.dart';
import 'package:bnn/screens/reel/user_info_section.dart';
import 'package:bnn/widgets/buttons/button-reel-action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:provider/provider.dart';
import '../../providers/reel_provider.dart';

class ReelScreen extends StatefulWidget {
  final int? reelId;

  const ReelScreen({Key? key, this.reelId}) : super(key: key);

  @override
  _ReelScreenState createState() => _ReelScreenState();
}

class _ReelScreenState extends State<ReelScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late VlcPlayerController _controller;

  // final ReelProvider _provider = ReelProvider();

  @override
  void initState() {
    super.initState();

    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   _controller = VlcPlayerController.network(
    //     "https://firebasestorage.googleapis.com/v0/b/testvideo-91d3a.appspot.com/o/4.mp4?alt=media&token=517ad60c-ca28-400e-ab46-49fb8c122d75",
    //     hwAcc: HwAcc.full,
    //     autoPlay: true,
    //     options: VlcPlayerOptions(),
    //   );
    //   await _controller.initialize();
    //   _provider.controller = _controller;
    //   _provider.loadVideo(_provider.currentReel!);
    // });

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.99),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    // Provider.of<ReelProvider>(context, listen: false).disposeController();
    super.dispose();
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
    return ChangeNotifierProvider(
      create: (context) => ReelProvider(),
      child: Consumer<ReelProvider>(
        builder: (context, reelProvider, child) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: <Widget>[
                if (reelProvider.loading)
                  const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                else
                  GestureDetector(
                    onVerticalDragEnd: (DragEndDetails details) {
                      if (details.velocity.pixelsPerSecond.dy > 0 ||
                          details.velocity.pixelsPerSecond.dy < 0 ||
                          details.velocity.pixelsPerSecond.dx > 0) {
                        _animationController.forward().then((_) {
                          _animationController.reverse();
                          reelProvider.controller?.pause();
                          reelProvider.nextStep();
                        });
                      }
                    },
                    child: SlideTransition(
                      position: _slideAnimation,
                      child:
                          // (reelProvider.isControllerInitialized)
                          //     ? ReelVideoPlayer(controller: _controller)
                          //     : const Center(
                          //         child: CircularProgressIndicator(
                          //             color: Colors.white),
                          //       ),
                          FutureBuilder<void>(
                        future: reelProvider.initializeVideoPlayerFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return VlcPlayer(
                              controller: reelProvider.controller!,
                              aspectRatio: 9 / 16,
                            );
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
                    icon:
                        const Icon(Icons.close, size: 20, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                if (reelProvider.currentReel != null)
                  Positioned(
                    bottom: 60,
                    right: 12,
                    child: ReelActionButtons(
                      reel: reelProvider.currentReel!,
                      onLike: () {
                        Provider.of<ReelProvider>(context, listen: false)
                            .toggleLikeReel();
                      },
                      onComment: () {
                        if (!reelProvider.currentReelId.isNaN) {
                          _showCommentDetail(
                              context, reelProvider.currentReelId);
                        }
                      },
                      onBookmark: () {
                        Provider.of<ReelProvider>(context, listen: false)
                            .toggleBookmarkReel();
                      },
                      onShare: () {
                        //TODO: Implement Share Functionality
                      },
                    ),
                  ),
                if (reelProvider.currentReel != null &&
                    reelProvider.currentReel!.userInfo != null)
                  Positioned(
                    bottom: 50.0,
                    left: 10.0,
                    child: UserInfoSection(
                      userInfo: reelProvider.currentReel!.userInfo!,
                      reelInfo: reelProvider.currentReel!,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
