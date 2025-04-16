import 'dart:typed_data';
import 'package:intl/intl.dart';

import 'package:bnn/providers/auth_provider.dart';
import 'package:bnn/providers/post_provider.dart';
import 'package:bnn/providers/profile_provider.dart';
import 'package:bnn/screens/chat/room.dart';
import 'package:bnn/screens/home/comments.dart';
import 'package:bnn/widgets/buttons/button-post-action.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:bnn/widgets/post/share_modal.dart';
import 'package:bnn/widgets/post/PostMediaViewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_supabase_chat_core/flutter_supabase_chat_core.dart';
import 'package:provider/provider.dart';

class PostItem extends StatefulWidget {
  final dynamic post;
  final int index;
  final String? userId;
  final Function(int) onDelete;

  const PostItem({
    Key? key,
    required this.post,
    required this.index,
    this.userId,
    required this.onDelete,
  }) : super(key: key);

  @override
  _PostItemState createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  bool isFriend = false;
  dynamic friendInfo;
  bool _isCheckingFriendStatus = false;

  @override
  void initState() {
    super.initState();
    _checkFriendStatus();
  }

  Future<void> _checkFriendStatus() async {
    if (!mounted || _isCheckingFriendStatus) return;

    _isCheckingFriendStatus = true;

    try {
      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);
      friendInfo =
          await profileProvider.getFriendInfo(widget.post['author_id']!);
      if (mounted) {
        setState(() {
          isFriend = friendInfo?["id"] != null;
        });
      }
    } finally {
      _isCheckingFriendStatus = false;
    }
  }

  Future<void> _showFriendDetail(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.all(20.0),
              height: 300.0,
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundImage: NetworkImage(widget.post['avatar']!),
                      ),
                      SizedBox(width: 6),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.post['username']!,
                            style: TextStyle(
                                fontFamily: "Nunito",
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text(
                            isFriend
                                ? "Friends since ${DateFormat('MMMM').format(DateTime.parse(friendInfo!["created_at"]))} ${DateTime.parse(friendInfo["created_at"]).year}"
                                : '',
                            style:
                                TextStyle(fontFamily: "Poppins", fontSize: 10),
                          ),
                        ],
                      )
                    ],
                  ),
                  Divider(
                    color: Colors.grey,
                    thickness: 1,
                    height: 30,
                  ),
                  _buildActionButton(
                    icon: Icons.mode_comment_outlined,
                    label: 'Message ${widget.post["first_name"]}',
                    onTap: () => _handleMessage(context),
                  ),
                  SizedBox(height: 10),
                  _buildActionButton(
                    icon: Icons.person_off_outlined,
                    label: isFriend
                        ? 'Unfollow ${widget.post["first_name"]}'
                        : 'Follow',
                    onTap: () => _handleFollow(context, setState),
                  ),
                  SizedBox(height: 10),
                  if (isFriend)
                    _buildActionButton(
                      icon: Icons.block_flipped,
                      label: 'Block ${widget.post["first_name"]}',
                      onTap: () {},
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(children: [
        SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFF4D4C4A),
            borderRadius: BorderRadius.circular(40),
          ),
          padding: EdgeInsets.all(13),
          child: Icon(
            icon,
            color: Colors.white,
            size: 17,
          ),
        ),
        SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            color: Color(0xFF4D4C4A),
            fontSize: 11,
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
            height: 1.50,
          ),
        )
      ]),
    );
  }

  Future<void> _handleMessage(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context);
    final meId = authProvider.user?.id;
    if (widget.post['author_id'] == meId) {
      CustomToast.showToastWarningTop(context, "You can't send message to you");
      return;
    }

    types.User otherUser = types.User(
      id: widget.post['author_id'],
      firstName: widget.post['first_name'],
      lastName: widget.post['last_name'],
      imageUrl: widget.post['avatar'],
    );

    final navigator = Navigator.of(context);
    final temp = await SupabaseChatCore.instance.createRoom(otherUser);

    var room = temp.copyWith(
        imageUrl: widget.post['avatar'],
        name: "${widget.post['first_name']} ${widget.post['last_name']}");

    navigator.pop();
    await navigator.push(
      MaterialPageRoute(
        builder: (context) => RoomPage(room: room),
      ),
    );
  }

  Future<void> _handleFollow(BuildContext context, StateSetter setState) async {
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    if (isFriend) {
      await profileProvider.unfollowPost(friendInfo!['id'], context);
      setState(() {
        isFriend = false;
      });
    } else {
      await profileProvider.followUserPost(widget.post['author_id']!, context);
      friendInfo =
          await profileProvider.getFriendInfo(widget.post['author_id']!);
      setState(() {
        isFriend = friendInfo?["id"] != null;
      });
    }
  }

  void _showCommentDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return CommentsModal(postId: widget.post['id']);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(
            color: Colors.grey,
            thickness: 1,
            height: 30,
          ),
          GestureDetector(
            onLongPress: () {
              final me =
                  Provider.of<AuthProvider>(context, listen: false).profile!;
              if (me.id == widget.post['author_id']) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: const Text(
                          'Are you sure you want to remove this post?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Close'),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          onPressed: () async {
                            await postProvider.deletePost(widget.post["id"]);
                            widget.onDelete(widget.index);
                            Navigator.of(context).pop();
                          },
                          child: const Text('Remove'),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (widget.userId == null) {
                      Navigator.pushNamed(
                        context,
                        '/user-profile',
                        arguments: {'userId': widget.post["author_id"]},
                      );
                    }
                  },
                  child: CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(widget.post['avatar']),
                  ),
                ),
                SizedBox(width: 5),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.post['name'] ?? "",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12.80,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          widget.post['username'] ?? "",
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                            fontSize: 12.80,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${widget.post['time'] ?? ""} ago',
                      style: TextStyle(
                        color: Color(0xFF3C3E42),
                        fontSize: 12.80,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                GestureDetector(
                  onTap: () => _showFriendDetail(context),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.asset(
                      'assets/images/icons/menu.png',
                      width: 20.0,
                      height: 20.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 5),
          Text(
            widget.post['content'],
            style: TextStyle(
              color: Color(0xFF272729),
              fontSize: 12.80,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
          ),
          if (widget.post['img_urls'].isNotEmpty)
            SizedBox(
              height: 140.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.post['img_urls'].length,
                itemBuilder: (context, index2) {
                  final fileType =
                      postProvider.getFileType(widget.post['img_urls'][index2]);
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PostMediaViewer(
                            mediaUrls: widget.post['img_urls'],
                            initialIndex: index2,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      child: fileType == "video"
                          ? FutureBuilder<Uint8List?>(
                              future: postProvider.generateThumbnail(
                                  widget.post['img_urls'][index2]),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2));
                                } else if (snapshot.hasData &&
                                    snapshot.data != null) {
                                  return Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Image.memory(snapshot.data!),
                                        Positioned(
                                          child: Icon(
                                            Icons.play_arrow,
                                            color: Colors.white,
                                          ),
                                        )
                                      ]);
                                } else {
                                  return Text('Failed to load thumbnail');
                                }
                              },
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.network(
                                widget.post['img_urls'][index2]!,
                                fit: BoxFit.cover,
                                width: 150.0,
                                height: 140.0,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
          SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ButtonPostAction(
                icon: Icons.favorite_border,
                count: widget.post['likes'].toString(),
                onTap: () async {
                  final postId = widget.post['id'];
                  final authorId = widget.post['author_id'];
                  await postProvider.toggleLike(postId, authorId, widget.index);
                },
              ),
              ButtonPostAction(
                icon: Icons.mode_comment_outlined,
                count: widget.post['comments'].toString(),
                onTap: () => _showCommentDetail(context),
              ),
              ButtonPostAction(
                icon: Icons.bookmark_outline,
                count: widget.post['bookmarks'].toString(),
                onTap: () async {
                  final postId = widget.post['id'];
                  await postProvider.toggleBookmark(postId, widget.index);
                },
              ),
              ButtonPostAction(
                icon: Icons.forward,
                count: widget.post['share'].toString(),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => ShareModal(
                      post: widget.post,
                      type: "post",
                    ),
                  );
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
