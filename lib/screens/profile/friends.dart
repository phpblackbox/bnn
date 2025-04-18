import 'package:bnn/screens/chat/room.dart';
import 'package:bnn/screens/profile/suggested.dart';
import 'package:bnn/screens/profile/user_profile.dart';
import 'package:bnn/utils/constants.dart';
import 'package:bnn/widgets/inputs/custom-input-field.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:flutter/material.dart';
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
  final supabase = Supabase.instance.client;
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>>? data = Constants.fakeFollwers;
  String searchQuery = "";
  List<Map<String, dynamic>> filltered = [];
  bool _loading = true;

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
      final userId = supabase.auth.currentUser!.id;
      List<Map<String, dynamic>> res =
          await supabase.rpc('get_friends', params: {
        'param_user_id': userId,
      });

      if (res.isNotEmpty) {
        for (int i = 0; i < res.length; i++) {
          final int mutal = await supabase.rpc('get_count_mutual_friends',
              params: {'usera': userId, 'userb': res[i]["id"]});

          setState(() {
            res[i]["mutal"] = '$mutal mutal friend';

            if (res[i].containsKey("created_at")) {
              DateTime createdAt = DateTime.parse(res[i]["created_at"]);

              res[i]["friend"] =
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
        });
      }
    } else {
      await supabase.auth.signOut();

      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> unfollowUser(String rId) async {
    await supabase.from('relationships').delete().eq('id', rId);

    Navigator.pop(context);
    await fetchdata();
  }

  Future<void> blockUser(int rId) async {
    await supabase
        .from('relationships')
        .update({'status': 'blocked'}).eq('id', rId);

    Navigator.pop(context);
    await fetchdata();
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
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: NetworkImage(data![index]['avatar']),
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
                color: Colors.grey,
                thickness: 1,
                height: 30,
              ),
              GestureDetector(
                onTap: () async {
                  final meId = supabase.auth.currentUser!.id;
                  if (data![index]['id'] == meId) {
                    CustomToast.showToastWarningTop(
                        context, "You can't send message to you");

                    return;
                  }
                  types.User otherUser = types.User(
                    id: data![index]['id'],
                    firstName: data![index]['first_name'],
                    lastName: data![index]['last_name'],
                    imageUrl: data![index]['avatar'],
                  );

                  final navigator = Navigator.of(context);

                  final temp =
                      await SupabaseChatCore.instance.createRoom(otherUser);

                  var room = temp.copyWith(
                      imageUrl: data![index]['avatar'],
                      name:
                          "${data![index]['first_name']} ${data![index]['last_name']}");

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
                  unfollowUser(data![index]["relationship_id"].toString());
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
                      color: Colors.white,
                      size: 17,
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
                      color: Colors.white,
                      size: 17,
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
                    Navigator.pushReplacement(context,
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
                  setState(() {
                    searchQuery = value;
                  });
                  if (value.isNotEmpty) {
                    final temp = data!.where((item) {
                      final username =
                          (item['username'] as String?)?.toLowerCase() ?? '';
                      final firstName =
                          (item['first_name'] as String?)?.toLowerCase() ?? '';
                      final lastName =
                          (item['last_name'] as String?)?.toLowerCase() ?? '';
                      final searchValue = value.toLowerCase();

                      return username.contains(searchValue) ||
                          firstName.contains(searchValue) ||
                          lastName.contains(searchValue);
                    }).toList();
                    filltered = temp;
                  }
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
              child: Skeletonizer(
                enabled: _loading,
                enableSwitchAnimation: true,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount:
                      searchQuery.isEmpty ? data!.length : filltered.length,
                  itemBuilder: (context, index) {
                    final item =
                        searchQuery.isEmpty ? data![index] : filltered[index];
                    return Container(
                      padding: EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () {
                          // Navigator.push(context,
                          //     MaterialPageRoute(builder: (context) => Chat()));
                        },
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            UserProfile(userId: item['id'])));
                              },
                              child: CircleAvatar(
                                radius: 25,
                                backgroundImage: NetworkImage(item['avatar']),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '${item['username']}',
                                        style: TextStyle(
                                          color: Color(0xFF4D4C4A),
                                          fontSize: 12,
                                          fontFamily: 'Nunito',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        '${item['first_name']} ${item['last_name']}',
                                        style: TextStyle(
                                          color: Color(0xFF8E8E8E),
                                          fontFamily: "Poppins",
                                          fontSize: 9,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    item['mutal'] ?? "",
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
