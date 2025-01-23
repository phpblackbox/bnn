import 'package:bnn/main.dart';
import 'package:bnn/screens/chat/room.dart';
import 'package:bnn/screens/home/OnePost.dart';
import 'package:bnn/screens/home/reel.dart';
import 'package:bnn/screens/profile/followers.dart';
import 'package:bnn/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_supabase_chat_core/flutter_supabase_chat_core.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  late List<dynamic> data = [
    {
      "id": 11,
      "created_at": "2025-01-21T07:02:44.7553+00:00",
      "user_id": "e09e81d7-5e8c-4885-9e68-b9725745f79e",
      "actor_id": "9e2a1bcb-0367-4998-8ecd-ac741907e893",
      "action_type": "like reel",
      "target_id": 2,
      "timeDiff": "today",
      "action": "Liked your post",
      "is_read": false,
      "content": null,
      "profiles": {
        "avatar":
            "https://prrbylvucoyewsezqcjn.supabase.co/storage/v1/object/public/avatars/9e2a1bcb-0367-4998-8ecd-ac741907e893_350906.png",
        "username": "slack",
        "last_name": "Reynolds",
        "first_name": "Dennis"
      }
    },
    {
      "id": 10,
      "created_at": "2025-01-21T06:55:38.607353+00:00",
      "user_id": "e09e81d7-5e8c-4885-9e68-b9725745f79e",
      "actor_id": "9e2a1bcb-0367-4998-8ecd-ac741907e893",
      "action_type": "comment reel",
      "target_id": 2,
      "timeDiff": "today",
      "action": "Liked your post",
      "is_read": false,
      "content": "notification test",
      "profiles": {
        "avatar":
            "https://prrbylvucoyewsezqcjn.supabase.co/storage/v1/object/public/avatars/9e2a1bcb-0367-4998-8ecd-ac741907e893_350906.png",
        "username": "slack",
        "last_name": "Reynolds",
        "first_name": "Dennis"
      }
    }
  ];

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    fetchdata();
  }

  void fetchdata() async {
    setState(() {
      _loading = true;
    });

    final userId = supabase.auth.currentUser?.id;

    final res = await supabase
        .from('notifications')
        .select('*, profiles(username, avatar, first_name, last_name)')
        .eq('is_read', false)
        .eq('user_id', userId!)
        .order('created_at', ascending: false);

    if (res.isNotEmpty) {
      try {
        for (int i = 0; i < res.length; i++) {
          final nowString = await supabase.rpc('get_server_time');
          DateTime now = DateTime.parse(nowString);
          DateTime createdAt = DateTime.parse(res[i]["created_at"]);
          Duration difference = now.difference(createdAt);
          res[i]['timeDiff'] = Constants().formatDuration(difference);

          res[i]['action'] = "";
          switch (res[i]['action_type']) {
            case "follow":
              res[i]['action'] = "Followed you";
              break;

            case "like post":
              res[i]['action'] = "Liked your post";
              break;

            case "like story":
              res[i]['action'] = "Liked your story";
              break;

            case "like reel":
              res[i]['action'] = "Liked your reel";
              break;

            case "comment post":
              res[i]['action'] = "Commented on your post";
              break;

            case "comment story":
              res[i]['action'] = "Message on your story";
              break;

            case "comment reel":
              res[i]['action'] = "Commented on your reel";
              break;
          }
        }
        setState(() {
          data = res;
        });
      } catch (e) {
        print('Caught error: $e');
        if (e.toString().contains("JWT expired")) {
          await supabase.auth.signOut();
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } else {
      setState(() {
        data = [];
      });
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          child: Text(
            "Notificaitons",
            style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 20.0),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, top: 4, right: 16, bottom: 4),
        child: Column(
          children: [
            Expanded(
              child: Skeletonizer(
                enabled: _loading,
                enableSwitchAnimation: true,
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: EdgeInsets.all(4),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                                data[index]['profiles']['avatar']!),
                            radius: 25,
                          ),
                          SizedBox(width: 6),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Text(
                                  data[index]['profiles']['username']!,
                                  style: TextStyle(
                                      color: Color(0xFF4D4C4A),
                                      fontFamily: "Nunito",
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  data[index]['timeDiff']!,
                                  style: TextStyle(
                                      color: Color(0xFF4D4C4A),
                                      fontFamily: "Nunito",
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ]),
                              SizedBox(height: 4),
                              Text(
                                data[index]['action']!,
                                style: TextStyle(
                                    color: Color(0xFF8A8B8F),
                                    fontFamily: "Nunito",
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: () async {
                              await supabase
                                  .from('notifications')
                                  .update({'is_read': true}).eq(
                                      'id', data[index]['id']);

                              switch (data[index]['action_type']) {
                                case "follow":
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              Followers())).then((value) {
                                    fetchdata();
                                  });
                                  break;

                                case "like post":
                                case "comment post":
                                  Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => OnePost(
                                                  postId: data[index]
                                                      ['target_id'])))
                                      .then((value) {
                                    fetchdata();
                                  });
                                  break;

                                case "like reel":
                                case "comment reel":
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => reel(
                                                reelId: data[index]
                                                    ['target_id'],
                                              ))).then((value) {
                                    fetchdata();
                                  });
                                  break;

                                case "like story":
                                case "comment story":
                                  final meId = supabase.auth.currentUser!.id;
                                  if (data[index]['actor_id'] == meId) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content:
                                          Text("You can't send message to you"),
                                    ));
                                    return;
                                  }

                                  types.User otherUser = types.User(
                                    id: data[index]['actor_id'],
                                    firstName: data[index]['profiles']
                                        ['avatar'],
                                    lastName: data[index]['profiles']
                                        ['last_name'],
                                    imageUrl: data[index]['profiles']['avatar'],
                                  );

                                  final navigator = Navigator.of(context);
                                  final temp = await SupabaseChatCore.instance
                                      .createRoom(otherUser);

                                  var room = temp.copyWith(
                                      imageUrl: data[index]['profiles']
                                          ['avatar'],
                                      name:
                                          "${data[index]['profiles']['first_name']} ${data[index]['profiles']['last_name']}");

                                  navigator.pop();

                                  await navigator.push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RoomPage(room: room),
                                    ),
                                  );
                                  break;
                              }
                            },
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: Color(0xFF8A8B8F),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
