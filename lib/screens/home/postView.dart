import 'package:bnn/main.dart';
import 'package:bnn/models/profiles.dart';
import 'package:bnn/screens/chat/room.dart';
import 'package:bnn/screens/home/Comments.dart';
import 'package:bnn/screens/profile/userProfile.dart';
import 'package:bnn/utils/constants.dart';
import 'package:bnn/utils/toast.dart';
import 'package:bnn/widgets/FullScreenImage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_supabase_chat_core/flutter_supabase_chat_core.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PostView extends StatefulWidget {
  final String? userId;
  final bool? bookmark;

  const PostView({super.key, this.userId, this.bookmark});

  @override
  _PostViewState createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  List<dynamic>? comments = [];
  List<dynamic>? posts = [];
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
        List<Map<String, dynamic>> data = [];

        if (widget.bookmark == true) {
          data = await supabase.rpc('get_post_bookmarks_by_author', params: {
            'param_user_id': userId,
          });
        } else {
          if (widget.userId != null) {
            data = await supabase.rpc('get_posts_by_userid', params: {
              'param_user_id': widget.userId,
            });
          } else {
            data = await supabase.from('view_posts').select();
          }
        }

        if (data.isNotEmpty) {
          setState(() {
            posts = data;
          });
        }

        for (int i = 0; i < posts!.length; i++) {
          dynamic res =
              await supabase.rpc('get_count_post_likes_by_postid', params: {
                    'param_post_id': posts![i]["id"],
                  }) ??
                  0;

          setState(() {
            posts![i]["likes"] = res;
          });

          res =
              await supabase.rpc('get_count_post_bookmarks_by_postid', params: {
            'param_post_id': posts![i]["id"],
          });

          setState(() {
            posts![i]["bookmarks"] = res;
          });

          res =
              await supabase.rpc('get_count_post_comments_by_postid', params: {
            'param_post_id': posts![i]["id"],
          });

          setState(() {
            posts![i]["comments"] = res;
            posts![i]["share"] = 2;
            posts![i]['name'] =
                '${posts![i]["first_name"]} ${posts![i]["last_name"]}';
          });

          final nowString = await supabase.rpc('get_server_time');
          DateTime now = DateTime.parse(nowString);
          DateTime createdAt = DateTime.parse(posts![i]["created_at"]);
          Duration difference = now.difference(createdAt);
          setState(() {
            posts![i]["time"] = Constants().formatDuration(difference);
          });

          setState(() {
            _loading = false;
          });
        }
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

  void _showFriendDetail(BuildContext context, int index) {
    showModalBottomSheet(
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
                    posts![index]['avatar']!,
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
                        posts![index]['name']!,
                        style: TextStyle(
                            fontFamily: "Nunito",
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        // posts[index]['friend']!,
                        "Friends since January 2025",
                        style: TextStyle(fontFamily: "Poppins", fontSize: 10),
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
                  if (posts![index]['author_id'] == meId) {
                    CustomToast.showToastWarningTop(
                        context, "You can't send message to you");
                    return;
                  }

                  types.User otherUser = types.User(
                    id: posts![index]['author_id'],
                    firstName: posts![index]['first_name'],
                    lastName: posts![index]['last_name'],
                    imageUrl: posts![index]['avatar'],
                  );

                  final navigator = Navigator.of(context);
                  final temp =
                      await SupabaseChatCore.instance.createRoom(otherUser);

                  var room = temp.copyWith(
                      imageUrl: posts![index]['avatar'],
                      name:
                          "${posts![index]['first_name']} ${posts![index]['last_name']}");

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
                    'Message ${posts![index]["first_name"]}',
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
                    'Unfollow  ${posts![index]["first_name"]}',
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
                    'Block ${posts![index]["first_name"]}',
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
    return Expanded(
      // height: widget.bookmark != null ? 220 : 360.0,
      child: Skeletonizer(
          enabled: _loading,
          enableSwitchAnimation: true,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: posts!.length,
            itemBuilder: (context, index) {
              return Column(
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
                                      userId: posts![index]["author_id"])));
                        },
                        child: CircleAvatar(
                          radius: 18,
                          backgroundImage:
                              NetworkImage(posts![index]['avatar']),
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
                                posts![index]['name'] ?? "",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12.80,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                posts![index]['username'] ?? "",
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
                            '${posts![index]['time'] ?? ""} ago',
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
                          _showFriendDetail(context, index);
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
                    posts![index]['content'],
                    style: TextStyle(
                      color: Color(0xFF272729),
                      fontSize: 12.80,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (posts![index]['img_urls'].isNotEmpty)
                    SizedBox(
                      height: 140.0,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: posts![index]['img_urls'].length,
                        itemBuilder: (context, index2) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => FullScreenImage(
                                      imageUrl: posts![index]['img_urls']
                                          [index2]!),
                                ),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 5.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.network(
                                  posts![index]['img_urls'][index2]!,
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
                              .eq('post_id', posts![index]['id'])
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
                                .eq('post_id', posts![index]['id']);

                            setState(() {
                              if (currentLikeStatus) posts![index]["likes"]--;
                              if (!currentLikeStatus) posts![index]["likes"]++;
                            });
                          } else {
                            await supabase.from('post_likes').upsert({
                              'author_id': userId,
                              'post_id': posts![index]['id'],
                              'is_like': true,
                            });

                            setState(() {
                              posts![index]["likes"]++;
                            });
                          }

                          final noti = await supabase
                              .from('notifications')
                              .select()
                              .eq('actor_id', userId)
                              .eq('user_id', posts![index]['author_id'])
                              .eq('action_type', 'like post')
                              .eq('target_id', posts![index]['id']);

                          if (userId != posts![index]['author_id'] &&
                              noti.isEmpty) {
                            await supabase.from('notifications').upsert({
                              'actor_id': userId,
                              'user_id': posts![index]['author_id'],
                              'action_type': 'like post',
                              'target_id': posts![index]['id'],
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
                                posts![index]['likes'].toString(),
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
                          _showCommentDetail(context, posts![index]['id']);
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
                                posts![index]['comments'].toString(),
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
                              .eq('post_id', posts![index]['id'])
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
                                .eq('post_id', posts![index]['id']);

                            setState(() {
                              if (currentBookmarksStatus) {
                                posts![index]["bookmarks"]--;
                              }
                              if (!currentBookmarksStatus) {
                                posts![index]["bookmarks"]++;
                              }
                            });
                          } else {
                            await supabase.from('post_bookmarks').upsert({
                              'author_id': userId,
                              'post_id': posts![index]['id'],
                              'is_bookmark': true,
                            });

                            setState(() {
                              posts![index]["bookmarks"]++;
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
                                posts![index]['bookmarks'].toString(),
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
                                posts![index]['share'].toString(),
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
              );
            },
          )),
    );
  }
}
