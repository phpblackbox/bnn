import 'dart:io';
import 'package:bnn/screens/reel/reel_comments.dart';
import 'package:bnn/screens/reel/user_info_section.dart';
import 'package:bnn/screens/reel/widgets/reel_action_buttons.dart';
import 'package:bnn/screens/reel/widgets/reel_video_player.dart';
import 'package:flutter/material.dart';
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
  late Animation<Offset> _slideUpAnimation;
  late Animation<double> _fadeAnimation;
  bool _isTransitioning = false;
  bool _isInitialized = false;
  ReelProvider? _reelProvider;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideUpAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.99),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Initialize provider using post frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProvider();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reelProvider = Provider.of<ReelProvider>(context, listen: false);
  }

  Future<void> _initializeProvider() async {
    if (!mounted) return;
    await _reelProvider?.initialize();
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _reelProvider?.close();
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

  Future<void> _handleSwipe() async {
    if (_isTransitioning) return;

    _isTransitioning = true;

    try {
      await _animationController.forward();
      _reelProvider?.controller?.pause();
      await _reelProvider?.nextStep();
      await _animationController.reverse();
    } catch (e) {
      print("Error during swipe transition: $e");
      await _animationController.reverse();
    } finally {
      _isTransitioning = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final reelProvider = Provider.of<ReelProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          if (!_isInitialized || reelProvider.loading)
            const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          else
            AbsorbPointer(
              absorbing: _isTransitioning,
              child: GestureDetector(
                onVerticalDragEnd: (DragEndDetails details) {
                  if (details.velocity.pixelsPerSecond.dy < -100) {
                    _handleSwipe();
                  }
                },
                child: SlideTransition(
                  position: _slideUpAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: FutureBuilder<void>(
                      future: reelProvider.initializeVideoPlayerFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return ReelVideoPlayer(
                            controller: reelProvider.controller,
                            isTransitioning: _isTransitioning,
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
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            top: Platform.isIOS ? 40 : 12,
            left: 0,
            child: IconButton(
              icon: const Icon(Icons.close, size: 20, color: Colors.white),
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
                  if (!reelProvider.currentReel!.id.isNaN) {
                    _showCommentDetail(context, reelProvider.currentReel!.id);
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
  }
}
