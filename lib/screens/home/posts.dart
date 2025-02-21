import 'package:bnn/providers/auth_provider.dart';
import 'package:bnn/providers/post_provider.dart';
import 'package:bnn/screens/chat/room.dart';
import 'package:bnn/screens/home/comments.dart';
import 'package:bnn/widgets/buttons/button-post-action.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:bnn/widgets/FullScreenImage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_supabase_chat_core/flutter_supabase_chat_core.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Posts extends StatefulWidget {
  final String? userId;
  final bool? bookmark;

  const Posts({super.key, this.userId, this.bookmark});

  @override
  _PostsState createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  List<dynamic> comments = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      final userId = authProvider.user?.id;
      if (userId != null) {
        postProvider.loadPosts(
            userId: widget.userId,
            bookmark: widget.bookmark,
            currentUserId: userId);
      }
    });
  }

  void _showFriendDetail(BuildContext context, int index, postProvider) {
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
                    postProvider.posts?[index]['avatar']!,
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
                        postProvider.posts?[index]['name']!,
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
                  final authProvider = Provider.of<AuthProvider>(context);
                  final meId = authProvider.user?.id;
                  if (postProvider.posts?[index]['author_id'] == meId) {
                    CustomToast.showToastWarningTop(
                        context, "You can't send message to you");
                    return;
                  }

                  types.User otherUser = types.User(
                    id: postProvider.posts?[index]['author_id'],
                    firstName: postProvider.posts?[index]['first_name'],
                    lastName: postProvider.posts?[index]['last_name'],
                    imageUrl: postProvider.posts?[index]['avatar'],
                  );

                  final navigator = Navigator.of(context);
                  final temp =
                      await SupabaseChatCore.instance.createRoom(otherUser);

                  var room = temp.copyWith(
                      imageUrl: postProvider.posts?[index]['avatar'],
                      name:
                          "${postProvider.posts?[index]['first_name']} ${postProvider.posts?[index]['last_name']}");

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
                    'Message ${postProvider.posts?[index]["first_name"]}',
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
                    'Unfollow  ${postProvider.posts?[index]["first_name"]}',
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
                    'Block ${postProvider.posts?[index]["first_name"]}',
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
    final postProvider = Provider.of<PostProvider>(context);
    return Expanded(
      child: Skeletonizer(
          enabled: postProvider.loading,
          enableSwitchAnimation: true,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: postProvider.posts?.length,
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
                          Navigator.pushNamed(
                            context,
                            '/user-profile',
                            arguments: {
                              'userId': postProvider.posts?[index]["author_id"]
                            },
                          );
                        },
                        child: CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(
                              postProvider.posts?[index]['avatar']),
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
                                postProvider.posts?[index]['name'] ?? "",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12.80,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                postProvider.posts?[index]['username'] ?? "",
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
                            '${postProvider.posts?[index]['time'] ?? ""} ago',
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
                          _showFriendDetail(context, index, postProvider);
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
                    postProvider.posts?[index]['content'],
                    style: TextStyle(
                      color: Color(0xFF272729),
                      fontSize: 12.80,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  postProvider.posts?[index]['img_urls'].isEmpty
                      ? Container()
                      : SizedBox(
                          height: 140.0,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount:
                                postProvider.posts?[index]['img_urls'].length,
                            itemBuilder: (context, index2) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => FullScreenImage(
                                          imageUrl: postProvider.posts?[index]
                                              ['img_urls'][index2]!),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Image.network(
                                      postProvider.posts?[index]['img_urls']
                                          [index2]!,
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
                        count: postProvider.posts![index]['likes'].toString(),
                        onTap: () async {
                          final postId = postProvider.posts?[index]['id'];
                          final authorId =
                              postProvider.posts?[index]['author_id'];

                          await postProvider.toggleLike(
                              postId, authorId, index);
                        },
                      ),
                      ButtonPostAction(
                        icon: Icons.mode_comment_outlined,
                        count:
                            postProvider.posts![index]['comments'].toString(),
                        onTap: () => _showCommentDetail(context,
                            postProvider.posts?[index]['id']), // Keep it short
                      ),
                      ButtonPostAction(
                        icon: Icons.bookmark_outline,
                        count:
                            postProvider.posts![index]['bookmarks'].toString(),
                        onTap: () async {
                          final postId = postProvider.posts?[index]['id'];

                          await postProvider.toggleBookmark(postId, index);
                        },
                      ),
                      ButtonPostAction(
                        icon: Icons.forward,
                        count: postProvider.posts![index]['share'].toString(),
                        onTap: () {
                          print('share');
                        },
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
