import 'dart:io';
import 'package:bnn/screens/reel/reel_comments.dart';
import 'package:bnn/screens/reel/user_info_section.dart';
import 'package:bnn/screens/reel/widgets/reel_action_buttons.dart';
import 'package:bnn/screens/reel/widgets/reel_video_player.dart';
import 'package:bnn/widgets/post/share_modal.dart';
import 'package:bnn/widgets/sub/bottom-navigation.dart';
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
  late Animation<Offset> _slideDownAnimation;
  late Animation<double> _fadeAnimation;
  bool _isTransitioning = false;
  bool _isInitialized = false;
  bool _isSlidingUp = true;
  bool _isHandlingPress = false;
  ReelProvider? _reelProvider;
  double _dragDistance = 0;

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

    _slideDownAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 0.99),
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
    await _reelProvider?.initialize(widget.reelId);
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> _cleanup() async {
    if (_reelProvider?.controller != null) {
      await _reelProvider?.controller?.pause();
      await _reelProvider?.controller?.dispose();
      _reelProvider?.controller = null;
    }
    _reelProvider?.close();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cleanup();
    super.dispose();
  }

  void _showCommentDetail(BuildContext context, int reelId) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return ReelComments(reelId: reelId);
      },
    );
  }

  Future<void> _handleSwipe() async {
    if (_isTransitioning || _isHandlingPress) return;

    setState(() {
      _isTransitioning = true;
      _isHandlingPress = true;
      _isSlidingUp = true;
    });

    try {
      await _animationController.forward();
      _reelProvider?.controller?.pause();
      await _reelProvider?.nextStep();
      _animationController.reset();
    } catch (e) {
      print("Error during swipe transition: $e");
      _animationController.reset();
    } finally {
      if (mounted) {
        setState(() {
          _isTransitioning = false;
          _isHandlingPress = false;
        });
      }
    }
  }

  Future<void> _handlePreviousSwipe() async {
    if (_isTransitioning || _isHandlingPress) return;

    setState(() {
      _isTransitioning = true;
      _isHandlingPress = true;
      _isSlidingUp = false;
    });

    try {
      await _animationController.forward();
      _reelProvider?.controller?.pause();
      await _reelProvider?.previousStep();
      _animationController.reset();
    } catch (e) {
      print("Error during previous swipe transition: $e");
      _animationController.reset();
    } finally {
      if (mounted) {
        setState(() {
          _isTransitioning = false;
          _isHandlingPress = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reelProvider = Provider.of<ReelProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        await _cleanup();
        return true;
      },
      child: Scaffold(
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
                  onVerticalDragUpdate: (DragUpdateDetails details) {
                    // Track the drag distance
                    _dragDistance += details.delta.dy;
                  },
                  onVerticalDragEnd: (DragEndDetails details) {
                    // Check both velocity and distance for more reliable swipe detection
                    if (details.velocity.pixelsPerSecond.dy.abs() > 150 ||
                        _dragDistance.abs() > 50) {
                      if (_dragDistance > 0) {
                        // Swipe down - go to previous
                        _handlePreviousSwipe();
                      } else {
                        // Swipe up - go to next
                        _handleSwipe();
                      }
                    }
                    // Reset drag distance
                    _dragDistance = 0;
                  },
                  onHorizontalDragEnd: (DragEndDetails details) {
                    // Handle horizontal swipes
                    if (details.velocity.pixelsPerSecond.dx.abs() > 150) {
                      if (details.velocity.pixelsPerSecond.dx > 0) {
                        // Swipe right - go to previous
                        _handlePreviousSwipe();
                      } else {
                        // Swipe left - go to next
                        _handleSwipe();
                      }
                    }
                  },
                  behavior:
                      HitTestBehavior.opaque, // Make the entire area tappable
                  child: SlideTransition(
                    position:
                        _isSlidingUp ? _slideUpAnimation : _slideDownAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: FutureBuilder<void>(
                        future: reelProvider.initializeVideoPlayerFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
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
              top: Platform.isIOS ? 50 : 12,
              right: 0,
              child: Row(
                children: [
                  if (reelProvider.currentReel != null &&
                      reelProvider.currentReel!.authorId ==
                          reelProvider.currentUserId)
                    IconButton(
                      icon: const Icon(Icons.delete,
                          size: 30, color: Colors.white),
                      onPressed: () async {
                        final shouldDelete = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Delete'),
                              content: Text(
                                  'Are you sure you want to delete this video?'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                ),
                                TextButton(
                                  child: Text('Delete',
                                      style: TextStyle(color: Colors.red)),
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                ),
                              ],
                            );
                          },
                        );

                        if (shouldDelete == true) {
                          try {
                            await reelProvider.deleteReel();
                            if (!mounted) return;
                            Navigator.pushReplacementNamed(context, '/home');
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to delete reel')),
                            );
                          }
                        }
                      },
                    ),
                  IconButton(
                    icon:
                        const Icon(Icons.close, size: 30, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
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
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => ShareModal(
                        post: reelProvider.currentReel!.id,
                        type: "reel",
                      ),
                    );
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
        bottomNavigationBar: BottomNavigation(currentIndex: 3),
      ),
    );
  }
}
