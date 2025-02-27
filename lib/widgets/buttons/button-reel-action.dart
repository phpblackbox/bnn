import 'package:flutter/material.dart';
import '../../models/reel_model.dart';

class ReelActionButtons extends StatelessWidget {
  final ReelModel reel;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onBookmark;
  final VoidCallback onShare;

  const ReelActionButtons({
    Key? key,
    required this.reel,
    required this.onLike,
    required this.onComment,
    required this.onBookmark,
    required this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildActionButton(
          icon: 'assets/images/icons/like.png',
          count: reel.likes,
          onTap: onLike,
        ),
        const SizedBox(height: 10),
        _buildActionButton(
          icon: 'assets/images/icons/comment2.png',
          count: reel.comments,
          onTap: onComment,
        ),
        const SizedBox(height: 10),
        _buildActionButton(
          icon: 'assets/images/icons/bookmark2.png',
          count: reel.bookmarks,
          onTap: onBookmark,
        ),
        const SizedBox(height: 10),
        _buildActionButton(
          icon: 'assets/images/icons/share.png',
          count: reel.share,
          onTap: onShare,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String icon,
    required int count,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: ImageIcon(
            AssetImage(icon),
            color: Colors.white,
            size: 27,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          count.toString(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
