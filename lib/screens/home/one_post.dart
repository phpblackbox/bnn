import 'package:bnn/main.dart';
import 'package:bnn/models/profiles.dart';
import 'package:bnn/screens/chat/room.dart';
import 'package:bnn/screens/home/comments.dart';
import 'package:bnn/screens/profile/user_profile.dart';
import 'package:bnn/utils/constants.dart';
import 'package:bnn/widgets/FullScreenImage.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_supabase_chat_core/flutter_supabase_chat_core.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnePost extends StatefulWidget {
  final int? postId;

  const OnePost({super.key, this.postId});

  @override
  _OnePostState createState() => _OnePostState();
}

class _OnePostState extends State<OnePost> {
  final supabase = Supabase.instance.client;

  List<dynamic>? comments = [];
  Map<String, dynamic>? post;
  Profiles? loadedProfile;

  int parent_id = 0;

  late FocusNode commentFocusNode;
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    commentFocusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      commentFocusNode.requestFocus();
    });

    fetchdata();
  }

  Future<void> fetchdata() async {
    loadedProfile = await Constants.loadProfile();

    if (supabase.auth.currentUser != null) {
      setState(() {
        _loading = true;
      });
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        print('User is not logged in!');
        return;
      }
      try {
        Map<String, dynamic> data = {};

        data = await supabase
            .from('posts')
            .select()
            .eq('id', widget.postId!)
            .single();

        if (data.isNotEmpty) {
          final userInfo = await supabase
              .from('profiles')
              .select()
              .eq('id', data['author_id'])
              .single();

          data['avatar'] = userInfo['avatar'];
          data['first_name'] = userInfo['first_name'];
          data['last_name'] = userInfo['last_name'];
          data['username'] = userInfo['username'];
          data['name'] = "${userInfo['first_name']} ${userInfo['last_name']}";

          setState(() {
            post = data;
          });
        }

        dynamic res =
            await supabase.rpc('get_count_post_likes_by_postid', params: {
                  'param_post_id': post!["id"],
                }) ??
                0;

        setState(() {
          post!["likes"] = res;
        });

        res = await supabase.rpc('get_count_post_bookmarks_by_postid', params: {
          'param_post_id': post!["id"],
        });

        setState(() {
          post!["bookmarks"] = res;
        });

        res = await supabase.rpc('get_count_post_comments_by_postid', params: {
          'param_post_id': post!["id"],
        });

        setState(() {
          post!["comments"] = res;
          post!["share"] = 2;
          post!['name'] = '${post!["first_name"]} ${post!["last_name"]}';
        });

        final nowString = await supabase.rpc('get_server_time');
        DateTime now = DateTime.parse(nowString);
        DateTime createdAt = DateTime.parse(post!["created_at"]);
        Duration difference = now.difference(createdAt);
        setState(() {
          post!["time"] = Constants().formatDuration(difference);
        });

        setState(() {
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
    setState(() {
      _loading = false;
    });
  }

  Future<List> fetchComments(postId) async {
    if (supabase.auth.currentUser != null) {
      try {
        List<Map<String, dynamic>> data =
            await supabase.rpc('get_post_comments_by_postid', params: {
          'param_post_id': postId,
        });

        if (data.isNotEmpty) {
          setState(() {
            comments = data;
          });
        }

        for (int i = 0; i < comments!.length; i++) {
          final nowString = await supabase.rpc('get_server_time');
          DateTime now = DateTime.parse(nowString);
          DateTime createdAt = DateTime.parse(comments![i]["created_at"]);

          Duration difference = now.difference(createdAt);

          setState(() {
            comments![i]['name'] =
                '${comments![i]["first_name"]} ${comments![i]["last_name"]}';

            comments![i]["time"] = Constants().formatDuration(difference);
          });
        }

        return comments!;
      } catch (e) {
        print('Caught error: $e');
        if (e.toString().contains("JWT expired")) {
          await supabase.auth.signOut();
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    }

    return comments!;
  }

  void _showFriendDetail(BuildContext context) {
    post == null
        ? null
        : showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return Container(
                padding: EdgeInsets.all(20.0),
                height: 300.0,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Image.network(
                          post!['avatar'],
                          fit: BoxFit.fill,
                          width: 70,
                          height: 70,
                        ),
                        SizedBox(width: 6),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post!['name'],
                              style: TextStyle(
                                  fontFamily: "Nunito",
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text(
                              // posts[index]['friend']!,
                              "Friends since January 2025",
                              style: TextStyle(
                                  fontFamily: "Poppins", fontSize: 10),
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
                    GestureDetector(
                      onTap: () async {
                        final meId = supabase.auth.currentUser!.id;
                        if (post!['author_id'] == meId) {
                          CustomToast.showToastWarningTop(
                              context, "You can't send message to you");
                          return;
                        }

                        types.User otherUser = types.User(
                          id: post!['author_id'],
                          firstName: post!['first_name'],
                          lastName: post!['last_name'],
                          imageUrl: post!['avatar'],
                        );

                        final navigator = Navigator.of(context);
                        final temp = await SupabaseChatCore.instance
                            .createRoom(otherUser);

                        var room = temp.copyWith(
                            imageUrl: post!['avatar'],
                            name:
                                "${post!['first_name']} ${post!['last_name']}");

                        print(room);

                        navigator.pop();
                        await navigator.push(
                          MaterialPageRoute(
                            builder: (context) => RoomPage(room: room),
                          ),
                        );
                      },
                      child: Row(children: [
                        SizedBox(width: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF4D4C4A),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          padding: EdgeInsets.all(13),
                          child: Icon(
                            Icons.mode_comment_outlined,
                            color: Colors.white,
                            size: 17,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Message ${post!["first_name"]}',
                          style: TextStyle(
                            color: Color(0xFF4D4C4A),
                            fontSize: 11,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                            height: 1.50,
                          ),
                        )
                      ]),
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {},
                      child: Row(children: [
                        SizedBox(width: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF4D4C4A),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          padding: EdgeInsets.all(13),
                          child: Icon(
                            Icons.person_off_outlined,
                            color: Colors.white,
                            size: 17,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Unfollow  ${post!["first_name"]}',
                          style: TextStyle(
                            color: Color(0xFF4D4C4A),
                            fontSize: 11,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                            height: 1.50,
                          ),
                        )
                      ]),
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {},
                      child: Row(children: [
                        SizedBox(width: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF4D4C4A),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          padding: EdgeInsets.all(13),
                          child: Icon(
                            Icons.block_flipped,
                            color: Colors.white,
                            size: 17,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Block ${post!["first_name"]}',
                          style: TextStyle(
                            color: Color(0xFF4D4C4A),
                            fontSize: 11,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                            height: 1.50,
                          ),
                        )
                      ]),
                    ),
                  ],
                ),
              );
            },
          );
  }

  void _showCommentDetail(BuildContext context, int postId) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return CommentsModal(postId: postId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 20.0),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        padding: EdgeInsets.all(8),
        child: Skeletonizer(
          enabled: _loading,
          enableSwitchAnimation: true,
          child: post == null
              ? Text('')
              : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(
                      color: Colors.grey,
                      thickness: 1,
                      height: 30,
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => UserProfile(
                                        userId: post!["author_id"])));
                          },
                          child: CircleAvatar(
                            radius: 18,
                            backgroundImage: NetworkImage(post!['avatar']),
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
                                  post!['name'] ?? "",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12.80,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  post!['username'] ?? "",
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
                              '${post!['time'] ?? ""} ago',
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
                          onTap: () {
                            _showFriendDetail(context);
                          },
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
                    SizedBox(height: 5),
                    Text(
                      post!['content'],
                      style: TextStyle(
                        color: Color(0xFF272729),
                        fontSize: 12.80,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (post!['img_urls'].isNotEmpty)
                      SizedBox(
                        height: 140.0,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: post!['img_urls'].length,
                          itemBuilder: (context, index2) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => FullScreenImage(
                                        imageUrl: post!['img_urls'][index2]!),
                                  ),
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 5.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Image.network(
                                    post!['img_urls'][index2]!,
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
                        GestureDetector(
                          onTap: () async {
                            final userId = supabase.auth.currentUser!.id;
                            final existingLikeResponse = await supabase
                                .from('post_likes')
                                .select()
                                .eq('author_id', userId)
                                .eq('post_id', post!['id'])
                                .maybeSingle();
                            if (existingLikeResponse != null) {
                              bool currentLikeStatus =
                                  existingLikeResponse['is_like'];
                              await supabase
                                  .from('post_likes')
                                  .update({
                                    'is_like': !currentLikeStatus,
                                  })
                                  .eq('author_id', userId)
                                  .eq('post_id', post!['id']);
                              setState(() {
                                if (currentLikeStatus) post!["likes"]--;
                                if (!currentLikeStatus) post!["likes"]++;
                              });
                            } else {
                              await supabase.from('post_likes').upsert({
                                'author_id': userId,
                                'post_id': post!['id'],
                                'is_like': true,
                              });
                              setState(() {
                                post!["likes"]++;
                              });
                            }
                            final noti = await supabase
                                .from('notifications')
                                .select()
                                .eq('actor_id', userId)
                                .eq('user_id', post!['author_id'])
                                .eq('action_type', 'like post')
                                .eq('target_id', post!['id']);
                            if (userId != post!['author_id'] && noti.isEmpty) {
                              await supabase.from('notifications').upsert({
                                'actor_id': userId,
                                'user_id': post!['author_id'],
                                'action_type': 'like post',
                                'target_id': post!['id'],
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 16.0),
                            decoration: ShapeDecoration(
                              color: Colors.black.withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(35),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.favorite_border,
                                  color: Colors.white,
                                  size: 16.0,
                                ),
                                SizedBox(width: 4.0),
                                Text(
                                  post!['likes'].toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _showCommentDetail(context, post!['id']);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 16.0), // Add padding
                            decoration: ShapeDecoration(
                              color: Colors.black.withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(35),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.mode_comment_outlined,
                                  color: Colors.white,
                                  size: 16.0,
                                ),
                                SizedBox(width: 4.0),
                                Text(
                                  post!['comments'].toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final userId = supabase.auth.currentUser!.id;
                            print(userId);
                            final existingBookmarksResponse = await supabase
                                .from('post_bookmarks')
                                .select()
                                .eq('author_id', userId)
                                .eq('post_id', post!['id'])
                                .maybeSingle();
                            if (existingBookmarksResponse != null) {
                              bool currentBookmarksStatus =
                                  existingBookmarksResponse['is_bookmark'];
                              await supabase
                                  .from('post_bookmarks')
                                  .update({
                                    'is_bookmark': !currentBookmarksStatus,
                                  })
                                  .eq('author_id', userId)
                                  .eq('post_id', post!['id']);
                              setState(() {
                                if (currentBookmarksStatus) {
                                  post!["bookmarks"]--;
                                }
                                if (!currentBookmarksStatus) {
                                  post!["bookmarks"]++;
                                }
                              });
                            } else {
                              await supabase.from('post_bookmarks').upsert({
                                'author_id': userId,
                                'post_id': post!['id'],
                                'is_bookmark': true,
                              });
                              setState(() {
                                post!["bookmarks"]++;
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 16.0),
                            decoration: ShapeDecoration(
                              color: Colors.black.withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(35),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.bookmark_outline,
                                  color: Colors.white,
                                  size: 16.0,
                                ),
                                SizedBox(width: 4.0),
                                Text(
                                  post!['bookmarks'].toString(),
                                  style: TextStyle(
                                    color: Colors
                                        .white, // Set text color to contrast with the background
                                    fontSize: 12.0, // Set font size
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            print('bakspace');
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 16.0),
                            decoration: ShapeDecoration(
                              color: Colors.black.withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(35),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.forward,
                                  color: Colors.white,
                                  size: 16.0,
                                ),
                                SizedBox(width: 4.0),
                                Text(
                                  post!['share'].toString(),
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
                    )
                  ],
                ),
        ),
      ),
    );
  }
}
