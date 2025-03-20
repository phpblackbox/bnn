import 'package:bnn/providers/auth_provider.dart';
import 'package:bnn/providers/notification_provider.dart';
import 'package:bnn/screens/chat/room.dart';
import 'package:bnn/screens/home/one_post.dart';
import 'package:bnn/screens/profile/followers.dart';
import 'package:bnn/screens/reel/reel.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_supabase_chat_core/flutter_supabase_chat_core.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:supabase_flutter/supabase_flutter.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    initialData();
  }

  void initialData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final NotificationProvider notificaitonProvider =
          Provider.of<NotificationProvider>(context, listen: false);
      await notificaitonProvider.getMyNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
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
                enabled: notificationProvider.loading,
                enableSwitchAnimation: true,
                child: ListView.builder(
                  itemCount: notificationProvider.data.length,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: EdgeInsets.all(4),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final meId = supabase.auth.currentUser!.id;
                              final userInfo =
                                  notificationProvider.data[index]['profiles'];
                              print(userInfo);
                              if (userInfo['id'] == meId) {
                                CustomToast.showToastWarningTop(
                                    context, "You can't send message to you");

                                return;
                              }
                              types.User otherUser = types.User(
                                id: userInfo['id'],
                                firstName: userInfo['first_name'],
                                lastName: userInfo['last_name'],
                                imageUrl: userInfo['avatar'],
                              );

                              final navigator = Navigator.of(context);

                              final temp = await SupabaseChatCore.instance
                                  .createRoom(otherUser);

                              var room = temp.copyWith(
                                  imageUrl: userInfo['avatar'],
                                  name:
                                      "${userInfo['first_name']} ${userInfo['last_name']}");

                              // navigator.pop();
                              await navigator.push(
                                MaterialPageRoute(
                                  builder: (context) => RoomPage(
                                    room: room,
                                  ),
                                ),
                              );
                            },
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(notificationProvider
                                  .data[index]['profiles']['avatar']!),
                              radius: 25,
                            ),
                          ),
                          SizedBox(width: 6),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Text(
                                  notificationProvider.data[index]['profiles']
                                      ['username']!,
                                  style: TextStyle(
                                      color: Color(0xFF4D4C4A),
                                      fontFamily: "Nunito",
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  notificationProvider.data[index]['timeDiff']!,
                                  style: TextStyle(
                                      color: Color(0xFF4D4C4A),
                                      fontFamily: "Nunito",
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ]),
                              SizedBox(height: 4),
                              Text(
                                notificationProvider.data[index]['action']!,
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
                              await notificationProvider.readNotificaiton(
                                  notificationProvider.data[index]['id']!);

                              switch (notificationProvider.data[index]
                                  ['action_type']) {
                                case "follow":
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              Followers())).then((value) {
                                    notificationProvider.getMyNotifications();
                                  });
                                  break;

                                case "like post":
                                case "comment post":
                                  Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => OnePost(
                                                  postId: notificationProvider
                                                          .data[index]
                                                      ['target_id'])))
                                      .then((value) {
                                    notificationProvider.getMyNotifications();
                                  });
                                  break;

                                case "like reel":
                                case "comment reel":
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ReelScreen(
                                                reelId: notificationProvider
                                                    .data[index]['target_id'],
                                              ))).then((value) {
                                    notificationProvider.getMyNotifications();
                                  });
                                  break;

                                case "like story":
                                case "comment story":
                                  final meId = Provider.of<AuthProvider>(
                                          context,
                                          listen: false)
                                      .user
                                      ?.id;
                                  if (notificationProvider.data[index]
                                          ['actor_id'] ==
                                      meId) {
                                    CustomToast.showToastWarningTop(context,
                                        "You can't send message to you");
                                    return;
                                  }

                                  types.User otherUser = types.User(
                                    id: notificationProvider.data[index]
                                        ['actor_id'],
                                    firstName: notificationProvider.data[index]
                                        ['profiles']['avatar'],
                                    lastName: notificationProvider.data[index]
                                        ['profiles']['last_name'],
                                    imageUrl: notificationProvider.data[index]
                                        ['profiles']['avatar'],
                                  );

                                  final navigator = Navigator.of(context);
                                  final temp = await SupabaseChatCore.instance
                                      .createRoom(otherUser);

                                  var room = temp.copyWith(
                                      imageUrl: notificationProvider.data[index]
                                          ['profiles']['avatar'],
                                      name:
                                          "${notificationProvider.data[index]['profiles']['first_name']} ${notificationProvider.data[index]['profiles']['last_name']}");

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
