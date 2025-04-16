import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PostMediaViewer extends StatefulWidget {
  final List<dynamic> mediaUrls;
  final int initialIndex;

  const PostMediaViewer({
    Key? key,
    required this.mediaUrls,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  _PostMediaViewerState createState() => _PostMediaViewerState();
}

class _PostMediaViewerState extends State<PostMediaViewer> {
  late PageController _pageController;
  VideoPlayerController? _videoController;
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _initializeVideoController(widget.initialIndex);
  }

  Future<void> _initializeVideoController(int index) async {
    final fileType = _getFileType(widget.mediaUrls[index].toString());
    if (fileType == 'video') {
      if (_videoController != null) {
        await _videoController!.pause();
        await _videoController!.dispose();
      }

      _videoController = VideoPlayerController.networkUrl(
          Uri.parse(widget.mediaUrls[index].toString()));
      await _videoController!.initialize();
      _videoController!.setLooping(true);
      _videoController!.play();
      setState(() {});
    } else {
      if (_videoController != null) {
        await _videoController!.pause();
        await _videoController!.dispose();
        _videoController = null;
        setState(() {});
      }
    }
  }

  String _getFileType(String path) {
    final fileExtension = path.split('.').last.toLowerCase();
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'tiff'];
    final videoExtensions = ['mp4', 'mov', 'avi', 'flv', 'wmv', 'mkv'];

    if (imageExtensions.contains(fileExtension)) {
      return 'image';
    } else if (videoExtensions.contains(fileExtension)) {
      return 'video';
    }
    return 'unknown';
  }

  Future<void> _closeViewer() async {
    if (_videoController != null && _videoController!.value.isInitialized) {
      await _videoController!.pause();
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _videoController?.pause();
    _videoController?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.mediaUrls.length,
            onPageChanged: (index) async {
              setState(() => _isTransitioning = true);
              if (_videoController != null &&
                  _videoController!.value.isInitialized) {
                await _videoController!.pause();
              }
              await _initializeVideoController(index);
              setState(() => _isTransitioning = false);
            },
            itemBuilder: (context, index) {
              final fileType = _getFileType(widget.mediaUrls[index].toString());

              if (fileType == 'video') {
                return _buildVideoPlayer();
              } else {
                return _buildImageViewer(widget.mediaUrls[index].toString());
              }
            },
          ),
          Positioned(
            top: 40,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: _closeViewer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        ),
        if (_isTransitioning)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageViewer(String imageUrl) {
    return GestureDetector(
      onTap: _closeViewer,
      child: Image.network(
        imageUrl,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}
