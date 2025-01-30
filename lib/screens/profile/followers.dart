import 'package:bnn/main.dart';
import 'package:bnn/screens/signup/ButtonGradientMain.dart';
import 'package:bnn/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:bnn/screens/signup/CustomInputField.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Followers extends StatefulWidget {
  const Followers({super.key});

  @override
  State<Followers> createState() => _FollowersState();
}

class _FollowersState extends State<Followers> {
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>>? data = Constants.fakeFollwers;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> followUser(String followerId) async {
    final followedId = supabase.auth.currentUser!.id;

    if (followerId == followedId) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("You can't follow yourself"),
      ));
      return;
    }

    dynamic res = await supabase
        .from('relationships')
        .select()
        .eq('follower_id', followerId)
        .eq('followed_id', followedId)
        .or('status.eq.following, status.eq.friend');

    if (res.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Already Followed!')),
      );

      return;
    }

    await supabase
        .from('relationships')
        .update({
          'status': 'friend',
        })
        .eq("follower_id", followerId)
        .eq("followed_id", followedId);

    await supabase.from('notifications').insert({
      'actor_id': followedId,
      'user_id': followerId,
      'action_type': 'follow'
    });

    fetchData();
  }

  Stream<List<Map<String, dynamic>>> getData() {
    supabase
        .channel('public:relationships')
        .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'relationships',
            callback: (payload) async {
              if (payload.eventType.toString() ==
                      "PostgresChangeEvent.update" ||
                  payload.eventType.toString() ==
                      "PostgresChangeEvent.insert") {
                final userId = supabase.auth.currentUser!.id;

                if (payload.newRecord["followed_id"] == userId &&
                    payload.newRecord["status"] == "following") {
                  Map<String, dynamic> res = await supabase
                      .rpc('get_relationship_follower_detail', params: {
                    'param_r_id': payload.newRecord["id"],
                  }).single();

                  if (res.isNotEmpty) {
                    final mutal = await supabase.rpc('get_count_mutual_friends',
                        params: {'usera': userId, 'userb': res["id"]});

                    res["mutal"] = '$mutal mutal friend';
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

  void fetchData() async {
    setState(() {
      _loading = true;
    });

    final userId = supabase.auth.currentUser!.id;
    print(userId);

    List<Map<String, dynamic>> res =
        await supabase.rpc('get_following', params: {
      'param_user_id': userId,
    });

    if (res.isNotEmpty) {
      for (int i = 0; i < res.length; i++) {
        final mutal = await supabase.rpc('get_count_mutual_friends',
            params: {'usera': userId, 'userb': res[i]["id"]});

        res[i]["mutal"] = '$mutal mutal friend';
        res[i]["name"] = res[i]["first_name"] + res[i]["last_name"];
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          child: Text(
            "Followers",
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
          children: [
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
            SizedBox(height: 20),
            if (data!.isNotEmpty)
              Container(
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
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return Container(
                            padding: EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () {},
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(data[index]['avatar']),
                                    radius: 25,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data[index]['name'] ?? "",
                                          style: TextStyle(
                                            color: Color(0xFF4D4C4A),
                                            fontSize: 12,
                                            fontFamily: 'Nunito',
                                            fontWeight: FontWeight.w700,
                                            height: 1.50,
                                          ),
                                        ),
                                        Text(
                                          data[index]['mutal'] ?? "",
                                          style: TextStyle(
                                            color: Color(0xFF4D4C4A),
                                            fontFamily: "Poppins",
                                            fontSize: 9,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 40),
                                  if (data[index]['status'] == 'following')
                                    Expanded(
                                      child: ButtonGradientMain(
                                        label: 'Follow',
                                        onPressed: () {
                                          followUser(data[index]['id']);
                                        },
                                        textColor: Colors.white,
                                        gradientColors: _loading
                                            ? [
                                                Colors.transparent,
                                                Colors.transparent
                                              ]
                                            : [
                                                Color(0xFF000000),
                                                Color(0xFF820200)
                                              ],
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
