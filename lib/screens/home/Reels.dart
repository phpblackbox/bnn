import 'dart:typed_data';

import 'package:bnn/screens/chat/room.dart';
import 'package:bnn/screens/reel/reel.dart';
import 'package:bnn/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_supabase_chat_core/flutter_supabase_chat_core.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:supabase_flutter/supabase_flutter.dart';

class Reels extends StatefulWidget {
  const Reels({super.key});

  @override
  _ReelsState createState() => _ReelsState();
}

class _ReelsState extends State<Reels> {
  final supabase = Supabase.instance.client;

  List<dynamic>? reels = [];

  bool _loading = false;

  @override
  void initState() {
    super.initState();

    fetchdata();
  }

  Future<void> fetchdata() async {
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
        List<Map<String, dynamic>> data =
            await supabase.from('view_reels').select();

        if (data.isNotEmpty) {
          for (int i = 0; i < data.length; i++) {
            dynamic res =
                await supabase.rpc('get_count_reel_likes_by_reelid', params: {
                      'param_reel_id': data[i]["id"],
                    }) ??
                    0;

            data[i]["likes"] = res;

            res = await supabase
                .rpc('get_count_reel_bookmarks_by_reelid', params: {
              'param_reel_id': data[i]["id"],
            });

            data[i]["bookmarks"] = res;

            res = await supabase
                .rpc('get_count_reel_comments_by_reelid', params: {
              'param_reel_id': data[i]["id"],
            });

            data[i]["comments"] = res;
            data[i]["share"] = 2;
            data[i]['name'] =
                '${data[i]["first_name"]} ${data[i]["last_name"]}';

            final nowString = await supabase.rpc('get_server_time');
            DateTime now = DateTime.parse(nowString);
            DateTime createdAt = DateTime.parse(data[i]["created_at"]);
            Duration difference = now.difference(createdAt);

            data[i]["time"] = Constants().formatDuration(difference);

            setState(() {
              reels = data;
              _loading = false;
            });
          }
        }
      } catch (e) {
        print('Caught error: $e');
        if (e.toString().contains("JWT expired")) {
          await supabase.auth.signOut();
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    }
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
                    reels![index]['avatar']!,
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
                        reels![index]['name']!,
                        style: TextStyle(
                            fontFamily: "Nunito",
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        // reels[index]['friend']!,
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
                  types.User otherUser = types.User(
                    id: reels![index]['author_id'],
                    firstName: reels![index]['first_name'],
                    lastName: reels![index]['last_name'],
                    imageUrl: reels![index]['avatar'],
                  );

                  final navigator = Navigator.of(context);
                  final room =
                      await SupabaseChatCore.instance.createRoom(otherUser);

                  navigator.pop();
                  await navigator.push(
                    MaterialPageRoute(
                      builder: (context) => RoomPage(
                        room: room,
                      ),
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
                    'Message ${reels![index]["first_name"]}',
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
                    'Unfollow  ${reels![index]["first_name"]}',
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
                    'Block ${reels![index]["first_name"]}',
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360.0,
      child: Skeletonizer(
        enabled: _loading,
        enableSwitchAnimation: true,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: reels!.length,
          itemBuilder: (context, index) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(
                  color: Colors.grey, // Color of the divider
                  thickness: 1, // Thickness of the divider
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ReelScreen(
                                  reelId: reels![index]['id'],
                                )));
                  },
                  child: FutureBuilder<Uint8List?>(
                    future: VideoThumbnail.thumbnailData(
                      video: reels![index]['video_url'],
                      imageFormat: ImageFormat.JPEG,
                      maxWidth: 400, // specify the width of the thumbnail
                      quality: 75, // specify the quality of the thumbnail
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Container(
                          height: 220,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: _loading
                                ? null
                                : DecorationImage(
                                    image: MemoryImage(snapshot.data!),
                                    fit: BoxFit.cover,
                                  ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 10, right: 10, top: 10, bottom: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Image.network(
                                      reels![index]['avatar']!,
                                      fit: BoxFit.fill,
                                      width: 36,
                                      height: 36,
                                    ),
                                    SizedBox(width: 5),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              reels![index]['name']!,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              reels![index]['username']!,
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.5),
                                                fontSize: 10,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          reels![index]['time']!,
                                          style: TextStyle(
                                            color: Color(0xFFFFFFFF),
                                            fontSize: 10,
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
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Image.asset(
                                          'assets/images/icons/menu1.png', // Path to your image
                                          width: 20.0,
                                          height: 20.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Spacer(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 5.0, horizontal: 16.0),
                                        decoration: ShapeDecoration(
                                          color: Color(0xFFE5E5E5)
                                              .withOpacity(0.4),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(35),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Icon(
                                              Icons.favorite_border,
                                              color: Colors.white,
                                              size: 16.0,
                                            ),
                                            SizedBox(width: 4.0),
                                            Text(
                                              reels![index]['likes'].toString(),
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
                                      onTap: () {},
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 5.0,
                                            horizontal: 16.0), // Add padding
                                        decoration: ShapeDecoration(
                                          color: Color(0xFFE5E5E5)
                                              .withOpacity(0.4),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(35),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Icon(
                                              Icons.mode_comment_outlined,
                                              color: Colors.white,
                                              size: 16.0,
                                            ),
                                            SizedBox(width: 4.0),
                                            Text(
                                              reels![index]['comments']
                                                  .toString(),
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
                                      onTap: () async {},
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 5.0,
                                            horizontal: 16.0), // Add padding
                                        decoration: ShapeDecoration(
                                          color: Color(0xFFE5E5E5)
                                              .withOpacity(0.4),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(35),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Icon(
                                              Icons.bookmark_outline,
                                              color: Colors.white,
                                              size: 16.0,
                                            ),
                                            SizedBox(width: 4.0),
                                            Text(
                                              reels![index]['bookmarks']
                                                  .toString(),
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
                                        print('bakspace');
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 5.0,
                                            horizontal: 16.0), // Add padding
                                        decoration: ShapeDecoration(
                                          color: Color(0xFFE5E5E5)
                                              .withOpacity(0.4),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(35),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment
                                              .center, // Center items horizontally
                                          children: <Widget>[
                                            Icon(
                                              Icons
                                                  .forward, // Replace with your desired icon
                                              color: Colors.white, // Icon color
                                              size: 16.0,
                                            ),
                                            SizedBox(width: 4.0),
                                            Text(
                                              reels![index]['share'].toString(),
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
                        );
                      } else {
                        return Container(
                          height: 220,
                          decoration: BoxDecoration(
                            color:
                                Colors.grey, // Placeholder color while loading
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
