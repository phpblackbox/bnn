import 'package:bnn/main.dart';
import 'package:bnn/screens/chat/room.dart';
import 'package:bnn/screens/profile/suggested.dart';
import 'package:bnn/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:bnn/screens/signup/CustomInputField.dart';
import 'package:flutter_supabase_chat_core/flutter_supabase_chat_core.dart';
import 'package:intl/intl.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:skeletonizer/skeletonizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Friends extends StatefulWidget {
  const Friends({super.key});

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>>? data = [
    {
      "id": "66cffab6-e17c-4a8d-a08c-6f6b8d118d31",
      "username": "Charlie",
      "avatar":
          "https://prrbylvucoyewsezqcjn.supabase.co/storage/v1/object/public/avatars/66cffab6-e17c-4a8d-a08c-6f6b8d118d31_156069.png",
      "mutal": "1 mutal friend",
    },
    {
      "id": "66cffab6-e17c-4a8d-a08c-6f6b8d118d31",
      "username": "Charlie Fake Faker FakerName",
      "avatar":
          "https://prrbylvucoyewsezqcjn.supabase.co/storage/v1/object/public/avatars/66cffab6-e17c-4a8d-a08c-6f6b8d118d31_156069.png",
      "mutal": "1 mutal friend",
    },
    {
      "id": "66cffab6-e17c-4a8d-a08c-6f6b8d118d31",
      "username": "Charlie Fake Faker FakerName",
      "avatar":
          "https://prrbylvucoyewsezqcjn.supabase.co/storage/v1/object/public/avatars/66cffab6-e17c-4a8d-a08c-6f6b8d118d31_156069.png",
      "mutal": "1 mutal friend",
    }
  ];

  bool _loading = true;

  void initState() {
    super.initState();
    fetchdata();
  }

  Future<void> fetchdata() async {
    if (supabase.auth.currentUser != null) {
      setState(() {
        _loading = true;
      });
      final userId = supabase.auth.currentUser!.id;
      List<Map<String, dynamic>> res =
          await supabase.rpc('get_friends', params: {
        'param_user_id': userId,
      });

      if (res.isNotEmpty) {
        for (int i = 0; i < data!.length; i++) {
          final int mutal = await supabase.rpc('get_count_mutual_friends',
              params: {'usera': userId, 'userb': data![i]["id"]});

          setState(() {
            data![i]["mutal"] = '$mutal mutal friend';

            if (data![i].containsKey("created_at")) {
              DateTime createdAt = DateTime.parse(data![i]["created_at"]);

              data![i]["friend"] =
                  "Friends since ${DateFormat('MMMM').format(createdAt)} ${createdAt.year}";
            }
          });
        }
        setState(() {
          data = res;
          _loading = false;
        });
      } else {
        setState(() {
          data = [];
          _loading = false;
          ;
        });
      }
    } else {
      await supabase.auth.signOut();

      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Stream<List<Map<String, dynamic>>> getData() {
    supabase
        .channel('public:relationships')
        .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'relationships',
            callback: (payload) async {
              if (payload.eventType.toString() ==
                  "PostgresChangeEvent.update") {
                print(payload);
                final userId = supabase.auth.currentUser!.id;

                if ((payload.newRecord["followed_id"] == userId ||
                        payload.newRecord["follower_id"] == userId) &&
                    payload.newRecord["status"] == "friend") {
                  Map<String, dynamic> res = await supabase
                      .rpc('get_relationship_follower_detail', params: {
                    'param_r_id': payload.newRecord["id"],
                  }).single();

                  print(res);

                  if (res.isNotEmpty) {
                    final mutal = await supabase.rpc('get_count_mutual_friends',
                        params: {'usera': userId, 'userb': res["id"]});

                    res["mutal"] = '${mutal} mutal friend';
                    res['name'] = '${res["first_name"]} ${res["last_name"]}';

                    setState(() {
                      data!.add(res);
                    });
                  }
                }
              }
            })
        .subscribe();

    return Stream.fromIterable([data!]);
  }

  Future<void> unfollowUser(String r_id) async {
    final followerId = supabase.auth.currentUser!.id;

    await supabase.from('relationships').delete().eq('id', r_id);

    Navigator.pop(context);
    await fetchdata();
  }

  Future<void> blockUser(int r_id) async {
    await supabase
        .from('relationships')
        .update({'status': 'blocked'}).eq('id', r_id);

    Navigator.pop(context);
    await fetchdata();
  }

  void _showFriendDetail(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow full-height modal
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20.0),
          height: 300.0, // Set the height of the modal
          child: Column(
            children: [
              Row(
                children: [
                  Image.network(
                    data![index]['avatar'],
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
                        data![index]['username'],
                        style: TextStyle(
                            fontFamily: "Nunito",
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        data![index]['friend'] ?? "",
                        style: TextStyle(fontFamily: "Poppins", fontSize: 10),
                      ),
                    ],
                  )
                ],
              ),
              Divider(
                color: Colors.grey, // Color of the divider
                thickness: 1, // Thickness of the divider
                height: 30, // Space around the divider
              ),
              GestureDetector(
                onTap: () async {
                  types.User otherUser = types.User(
                    id: data![index]['author_id'],
                    firstName: data![index]['first_name'],
                    lastName: data![index]['last_name'],
                    imageUrl: data![index]['avatar'],
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
                      color: Colors.white, // Icon color
                      size: 17, // Icon size
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Message ${data![index]["username"]}',
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
                onTap: () {
                  unfollowUser(data![index]["relationship_id"]);
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
                      Icons.person_off_outlined,
                      color: Colors.white, // Icon color
                      size: 17, // Icon size
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Unfollow  ${data![index]["username"]}',
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
                onTap: () {
                  blockUser(data![index]["relationship_id"]);
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
                      Icons.block_flipped,
                      color: Colors.white, // Icon color
                      size: 17, // Icon size
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Block ${data![index]["username"]}',
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
    return Scaffold(
      appBar: AppBar(
        title: Container(
          child: Text(
            "Friends",
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
      body: Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Suggested()));
                  },
                  child: Text(
                    'Suggested',
                    style: TextStyle(
                      color: Color(0x884D4C4A),
                      fontSize: 20,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  ' | ',
                  style: TextStyle(
                    color: Color(0xFF4D4C4A),
                    fontSize: 20,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: Text(
                    'Friends',
                    style: TextStyle(
                      color: Color(0xFF4D4C4A),
                      fontSize: 20,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Container(
              child: CustomInputField(
                placeholder: "Search for friends",
                controller: searchController,
                onChanged: (value) {
                  setState(() {}); // Update state on input field change
                },
                icon: Icons.search,
              ),
            ),
            SizedBox(height: 16),
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(children: [
                        Image(
                            image: AssetImage("assets/images/icons/invite.png"),
                            width: 40,
                            height: 40),
                        SizedBox(width: 10),
                        Text(
                          'Invite friends',
                          style: TextStyle(
                            color: Color(0xFF4D4C4A),
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ]),
                    ),
                    Icon(Icons.arrow_forward_ios,
                        size: 12, color: Color(0xFF8A8B8F)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Row(children: [
                        Image(
                            image: AssetImage("assets/images/icons/find.png"),
                            width: 40,
                            height: 40),
                        SizedBox(width: 10),
                        Text(
                          'Find contacts',
                          style: TextStyle(
                            color: Color(0xFF4D4C4A),
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ]),
                    ),
                    Icon(Icons.arrow_forward_ios,
                        size: 12, color: Color(0xFF8A8B8F)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Row(children: [
                        Image(
                            image:
                                AssetImage("assets/images/icons/facebook.png"),
                            width: 40,
                            height: 40),
                        SizedBox(width: 10),
                        Text(
                          'Find Facebook friends',
                          style: TextStyle(
                            color: Color(0xFF4D4C4A),
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ]),
                    ),
                    Icon(Icons.arrow_forward_ios,
                        size: 12, color: Color(0xFF8A8B8F)),
                  ],
                ),
                SizedBox(height: 8),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Friends',
              style: TextStyle(
                color: Color(0xFF4D4C4A),
                fontSize: 15,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: getData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    if (snapshot.error.toString().contains("JWT expired")) {
                      supabase.auth.signOut();
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final data = snapshot.data ?? [];
                  print("data =  ${data.toString()}");

                  return Skeletonizer(
                    enabled: _loading,
                    enableSwitchAnimation: true,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: data!.length,
                      itemBuilder: (context, index) {
                        return Container(
                          padding: EdgeInsets.only(bottom: 12),
                          // margin: EdgeInsets.all(8),
                          child: GestureDetector(
                            onTap: () {
                              // Navigator.push(context,
                              //     MaterialPageRoute(builder: (context) => Chat()));
                            },
                            child: Row(
                              children: [
                                Image.network(
                                  data![index]['avatar']!,
                                  fit: BoxFit.fill,
                                  width: 50,
                                  height: 50,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data![index]['username'],
                                        style: TextStyle(
                                          color: Color(0xFF4D4C4A),
                                          fontSize: 12,
                                          fontFamily: 'Nunito',
                                          fontWeight: FontWeight.w700,
                                          height: 1.50,
                                        ),
                                      ),
                                      Text(
                                        data![index]['mutal'] ?? "",
                                        style: TextStyle(
                                          color: Color(0xFF4D4C4A),
                                          fontFamily: "Poppins",
                                          fontSize: 9,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _showFriendDetail(context, index);
                                  },
                                  child: ImageIcon(
                                    AssetImage('assets/images/icons/menu.png'),
                                    color: Color(0xFF4D4C4A),
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
