import 'package:bnn/main.dart';
import 'package:flutter/material.dart';
import 'package:bnn/models/profiles.dart';
import 'package:bnn/utils/constants.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ReelCommands extends StatefulWidget {
  final int reelId;

  const ReelCommands({super.key, required this.reelId});

  @override
  _ReelCommandsState createState() => _ReelCommandsState();
}

class _ReelCommandsState extends State<ReelCommands> {
  // late List<dynamic> _parentComments = [];
  final Map<String, List<dynamic>> _childCommentsMap = {};

  late List<dynamic> _parentComments = [
    {
      "id": "1",
      "name": "User One",
      "time": "2 hours ago",
      "content": "This is a comment.",
      "likes": 5,
      "profiles": {
        "avatar":
            "https://prrbylvucoyewsezqcjn.supabase.co/storage/v1/object/public/avatars/66cffab6-e17c-4a8d-a08c-6f6b8d118d31_156069.png"
      }
    },
    {
      "id": "2",
      "name": "User Two",
      "time": "1 hour ago",
      "content": "This is another comment.",
      "likes": 3,
      "profiles": {
        "avatar":
            "https://prrbylvucoyewsezqcjn.supabase.co/storage/v1/object/public/avatars/66cffab6-e17c-4a8d-a08c-6f6b8d118d31_156069.png"
      }
    },
    {
      "id": "2",
      "name": "User Two",
      "time": "1 hour ago",
      "content": "This is another comment.",
      "likes": 3,
      "profiles": {
        "avatar":
            "https://prrbylvucoyewsezqcjn.supabase.co/storage/v1/object/public/avatars/66cffab6-e17c-4a8d-a08c-6f6b8d118d31_156069.png"
      }
    },
    {
      "id": "2",
      "name": "User Two",
      "time": "1 hour ago",
      "content": "This is another comment.",
      "likes": 3,
      "profiles": {
        "avatar":
            "https://prrbylvucoyewsezqcjn.supabase.co/storage/v1/object/public/avatars/66cffab6-e17c-4a8d-a08c-6f6b8d118d31_156069.png"
      }
    },
  ];

  final List<String> _expandedComments = [];
  late int parentId = 0;
  late FocusNode commentFocusNode;
  final TextEditingController _commentController = TextEditingController();
  Profiles? loadedProfile;
  bool _loading = true;

  Future<List<dynamic>> fetchParentComments() async {
    final res = await Constants.loadProfile();

    setState(() {
      loadedProfile = res;
      _loading = true;
    });

    final data = await supabase
        .from('reel_comments')
        .select('*, profiles(username, avatar, first_name, last_name)')
        .eq('parent_id', 0)
        .eq('reel_id', widget.reelId)
        .order('created_at', ascending: false);

    for (int i = 0; i < data.length; i++) {
      final nowString = await supabase.rpc('get_server_time');
      DateTime now = DateTime.parse(nowString);
      DateTime createdAt = DateTime.parse(data[i]["created_at"]);

      Duration difference = now.difference(createdAt);

      data[i]['name'] =
          '${data[i]["profiles"]["first_name"]} ${data[i]["profiles"]["last_name"]}';

      data[i]["time"] = Constants().formatDuration(difference);
    }

    return data;
  }

  void fetchData() async {
    final comments = await fetchParentComments();
    setState(() {
      _parentComments = comments;
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();

    commentFocusNode = FocusNode();
    fetchData();
  }

  Future<void> _toggleChildComments(String parentId) async {
    if (_expandedComments.contains(parentId)) {
      setState(() {
        _expandedComments.remove(parentId);
      });
    } else {
      final childComments = await fetchChildComments(parentId);
      setState(() {
        _childCommentsMap[parentId] = childComments;
        _expandedComments.add(parentId);
      });
    }
  }

  Future<List<dynamic>> fetchChildComments(String parentId) async {
    final data = await supabase
        .from('reel_comments')
        .select('*, profiles(username, avatar, first_name, last_name)')
        .eq('parent_id', parentId)
        .eq('reel_id', widget.reelId)
        .order('created_at', ascending: false);

    for (int i = 0; i < data.length; i++) {
      final nowString = await supabase.rpc('get_server_time');
      DateTime now = DateTime.parse(nowString);
      DateTime createdAt = DateTime.parse(data[i]["created_at"]);

      Duration difference = now.difference(createdAt);

      data[i]['name'] =
          '${data[i]["profiles"]["first_name"]} ${data[i]["profiles"]["last_name"]}';

      data[i]["time"] = Constants().formatDuration(difference);
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
              enabled: _loading,
              enableSwitchAnimation: true,
              child: ListView.builder(
                itemCount: _parentComments.length,
                itemBuilder: (context, index) {
                  final comment = _parentComments[index];
                  return buildCommentItem(comment);
                },
              ),
            ),
          ),
          if (loadedProfile != null) buildCommentInput(),
        ],
      ),
    );
  }

  Widget buildCommentItem(dynamic comment) {
    bool isExpanded = _expandedComments.contains(comment['id'].toString());
    List<dynamic>? childComments = _childCommentsMap[comment['id'].toString()];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(comment["profiles"]['avatar']),
              backgroundColor: Colors.transparent,
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
                    Text(
                      comment['content'],
                      style: TextStyle(
                        color: Color(0xFF151923),
                        fontSize: 12,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w400,
                        height: 1.37,
                      ),
                    ),
                    SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          parentId = comment["id"];
                        });
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
                  ]),
                  SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => _toggleChildComments(comment['id'].toString()),
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
                var currentLikes = comment['likes'] + 1;

                await supabase.from('reel_comments').update({
                  'likes': currentLikes,
                }).eq('id', comment['id']);

                setState(() {
                  comment['likes']++;
                });
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
        if (isExpanded && childComments != null && childComments.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              children: childComments.map((childComment) {
                return buildCommentItem(childComment);
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget buildCommentInput() {
    return SizedBox(
      height: 30,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 15,
            backgroundImage: NetworkImage(loadedProfile!.avatar),
            backgroundColor: Colors.grey[200],
          ),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              focusNode: commentFocusNode,
              controller: _commentController,
              onSubmitted: (value) async {
                if (value.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Add a comment')),
                  );
                  return;
                }

                final userId = supabase.auth.currentUser!.id;
                await supabase.from('reel_comments').upsert({
                  'author_id': userId,
                  'reel_id': widget.reelId,
                  'parent_id': parentId,
                  'content': value,
                });

                final reel_author_userInfo = await supabase
                    .from('reels')
                    .select()
                    .eq('id', widget.reelId)
                    .single();

                if (reel_author_userInfo.isNotEmpty) {
                  if (userId != reel_author_userInfo['author_id']) {
                    await supabase.from('notifications').upsert({
                      'actor_id': userId,
                      'user_id': reel_author_userInfo['author_id'],
                      'action_type': 'comment reel',
                      'target_id': widget.reelId,
                      'content': value,
                    });
                  }
                }

                final res = await supabase
                    .from('reel_comments')
                    .select()
                    .eq('author_id', userId)
                    .eq('reel_id', widget.reelId)
                    .eq('content', value)
                    .order('created_at', ascending: false)
                    .limit(1)
                    .single();

                final userInfo = await supabase
                    .from('profiles')
                    .select()
                    .eq("id", userId)
                    .single();

                if (userInfo.isNotEmpty) {
                  final nowString = await supabase.rpc('get_server_time');
                  DateTime now = DateTime.parse(nowString);
                  DateTime createdAt = DateTime.parse(res["created_at"]);
                  Duration difference = now.difference(createdAt);

                  dynamic temp = {
                    "id": res["id"],
                    "author_id": userId,
                    "name":
                        '${userInfo["first_name"]} ${userInfo["last_name"]}',
                    "reel_id": widget.reelId,
                    "parent_id": parentId,
                    "content": value,
                    "likes": res["likes"],
                    "created_at": res["created_at"],
                    "time": Constants().formatDuration(difference),
                    "profiles": {
                      "avatar": userInfo["avatar"],
                      "first_name": userInfo["first_name"],
                      "last_name": userInfo["last_name"],
                    }
                  };

                  if (parentId == 0) {
                    setState(() {
                      _parentComments.insert(0, temp);
                    });
                  } else {
                    print(_expandedComments);
                    final childComments =
                        await fetchChildComments(parentId.toString());
                    setState(() {
                      _childCommentsMap[parentId.toString()] = childComments;
                      _expandedComments.add(parentId.toString());
                    });
                  }
                }

                _commentController.clear(); // Clear the input field
                setState(() {
                  parentId = 0;
                });
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
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
