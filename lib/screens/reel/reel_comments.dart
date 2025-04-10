import 'package:bnn/providers/auth_provider.dart';
import 'package:bnn/providers/reel_comment_provider.dart';
import 'package:bnn/providers/reel_provider.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ReelComments extends StatefulWidget {
  final int reelId;

  const ReelComments({super.key, required this.reelId});

  @override
  _ReelCommentsState createState() => _ReelCommentsState();
}

class _ReelCommentsState extends State<ReelComments> {
  late FocusNode commentFocusNode;
  final TextEditingController _commentController = TextEditingController();

  void initialData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final ReelCommentProvider reelCommentProvider =
          Provider.of<ReelCommentProvider>(context, listen: false);
      await reelCommentProvider.getParentComments(widget.reelId);
    });
  }

  @override
  void initState() {
    super.initState();
    commentFocusNode = FocusNode();
    initialData();
  }

  @override
  Widget build(BuildContext context) {
    final ReelCommentProvider reelCommentProvider =
        Provider.of<ReelCommentProvider>(context);
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.all(16.0),
        height: MediaQuery.of(context).size.height * 0.5,
        child: Column(
          children: [
            Text(
              'Comments',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF151923),
                fontSize: 13.20,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: Skeletonizer(
                enabled: reelCommentProvider.loading,
                enableSwitchAnimation: true,
                child: ListView.builder(
                  itemCount: reelCommentProvider.parentComments.length,
                  itemBuilder: (context, index) {
                    final comment = reelCommentProvider.parentComments[index];
                    return buildCommentItem(comment, reelCommentProvider);
                  },
                ),
              ),
            ),
            FutureBuilder<Widget>(
              future: buildCommentInput(reelCommentProvider),
              builder: (context, snapshot) {
                return snapshot.data ?? Container();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCommentItem(
      dynamic comment, ReelCommentProvider reelCommentProvider) {
    bool isExpanded =
        reelCommentProvider.expandedComments.contains(comment['id'].toString());
    List<dynamic>? childComments =
        reelCommentProvider.childCommentsMap[comment['id'].toString()];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onLongPress: () {
            final me =
                Provider.of<AuthProvider>(context, listen: false).profile!;
            me.id == comment['author_id']
                ? showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: const Text(
                            'Are you sure you want to remove this comment?'),
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
                              await reelCommentProvider.deleteComment(
                                  comment['id'], widget.reelId);

                              Navigator.of(context).pop();
                            },
                            child: const Text('Remove'),
                          ),
                        ],
                      );
                    },
                  )
                : null;
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () async {
                  Navigator.pushNamed(
                    context,
                    '/user-profile',
                    arguments: {'userId': comment["author_id"]},
                  );
                },
                child: CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(comment["profiles"]['avatar']),
                  backgroundColor: Colors.transparent,
                ),
              ),
              SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(
                        comment['name']!,
                        style: TextStyle(
                          color: Color(0xFF8A8B8F),
                          fontFamily: "Nunito",
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 3),
                      Text(
                        comment['time']!,
                        style: TextStyle(
                          color: Color(0xFF8A8B8F),
                          fontFamily: "Nunito",
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ]),
                    SizedBox(height: 6),
                    Row(children: [
                      Expanded(
                        child: Text(
                          comment['content'],
                          style: TextStyle(
                            color: Color(0xFF151923),
                            fontSize: 12,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w400,
                            height: 1.37,
                          ),
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ]),
                    SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {
                        reelCommentProvider.parentId = comment["id"];
                        commentFocusNode.requestFocus();
                      },
                      child: Text(
                        'Reply',
                        style: TextStyle(
                          color: Color(0xFF939292),
                          fontSize: 10,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    SizedBox(height: 6),
                    GestureDetector(
                      onTap: () => reelCommentProvider.toggleChildComments(
                          widget.reelId, comment['id'].toString()),
                      child: Text(
                        isExpanded ? 'Hide Replies' : 'View more replies',
                        style: TextStyle(
                          color: Color(0xFF8A8B8F),
                          fontSize: 10,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final bool status =
                      await reelCommentProvider.toggleReelLike(comment['id']);
                  if (status) comment['likes']--;
                  if (!status) comment['likes']++;
                },
                child: Column(
                  children: [
                    Icon(Icons.favorite_outline, color: Color(0xFF8A8B8F)),
                    Text(comment['likes'].toString(),
                        style: TextStyle(color: Color(0xFF8A8B8F))),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (isExpanded && childComments != null && childComments.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              children: childComments.map((childComment) {
                return buildCommentItem(childComment, reelCommentProvider);
              }).toList(),
            ),
          ),
      ],
    );
  }

  Future<Widget> buildCommentInput(
      ReelCommentProvider reelCommentProvider) async {
    final me = Provider.of<AuthProvider>(context, listen: false).profile!;
    final reel = await Provider.of<ReelProvider>(context, listen: false)
        .getReelById(widget.reelId);
    return me.id != reel!.authorId
        ? Container(
            constraints: BoxConstraints(
              minHeight: 30,
              maxHeight: 120,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundImage: NetworkImage(me.avatar!),
                  backgroundColor: Colors.grey[200],
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Focus(
                    child: TextFormField(
                      focusNode: commentFocusNode,
                      controller: _commentController,
                      maxLines: null,
                      minLines: 1,
                      textInputAction: TextInputAction.send,
                      onFieldSubmitted: (value) async {
                        if (value.isEmpty) {
                          CustomToast.showToastWarningTop(
                              context, 'Add a comment');
                          return;
                        }

                        _commentController.clear();
                        reelCommentProvider.sendReelComment(
                            widget.reelId, value, me);
                      },
                      style: TextStyle(
                        fontSize: 10.0,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        filled: true,
                        fillColor: Color(0xFFE9E9E9),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        : Container();
  }
}
