import 'package:bnn/utils/constants.dart';
import 'package:bnn/widgets/FullScreenImage.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostBookmarks extends StatefulWidget {
  const PostBookmarks({super.key});

  @override
  State<PostBookmarks> createState() => _PostBookmarksState();
}

class _PostBookmarksState extends State<PostBookmarks> {
  final supabase = Supabase.instance.client;

  bool _loading = false;
  List<dynamic>? posts = [];

  @override
  void initState() {
    super.initState();
    fetchdata();
  }

  void fetchdata() async {
    final userId = supabase.auth.currentUser!.id;
    final data = await supabase
        .from('post_bookmarks')
        .select('post_bookmarks.id, post_bookmarks.author_id')
        .eq('post_bookmarks.author_id', userId);

    if (data.isNotEmpty) {
      setState(() {
        // posts = data;
        _loading = true;
      });

      for (int i = 0; i < data.length; i++) {
        dynamic res =
            await supabase.rpc('get_count_post_likes_by_postid', params: {
                  'param_post_id': data[i]["id"],
                }) ??
                0;
        data[i]["likes"] = res;

        res = await supabase.rpc('get_count_post_bookmarks_by_postid', params: {
          'param_post_id': data[i]["id"],
        });
        data[i]["bookmarks"] = res;

        res = await supabase.rpc('get_count_post_comments_by_postid', params: {
          'param_post_id': data[i]["id"],
        });
        data[i]["comments"] = res;
        data[i]["share"] = 2;
        data[i]['name'] = '${data[i]["first_name"]} ${data[i]["last_name"]}';

        final nowString = await supabase.rpc('get_server_time');
        DateTime now = DateTime.parse(nowString);
        DateTime createdAt = DateTime.parse(data[i]["created_at"]);
        Duration difference = now.difference(createdAt);
        data[i]["time"] = Constants().formatDuration(difference);
      }

      setState(() {
        posts = data;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
        child: Skeletonizer(
            enabled: _loading,
            enableSwitchAnimation: true,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: posts!.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Color(0x7CA6A8AB), width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(4),
                  margin: EdgeInsets.all(4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        posts![index]['content'],
                        style: TextStyle(
                          color: Color(0xFF272729),
                          fontSize: 12.80,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
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
                                                [index2] ??
                                            ''),
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
                                    width: 160.0,
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
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () async {},
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
                              // _showCommentDetail(context, posts![index]['id']);
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
                            onTap: () async {},
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
                );
              },
            )),
      ),
    );
  }
}
