import 'package:bnn/screens/profile/friends.dart';
import 'package:bnn/screens/profile/user_profile.dart';
import 'package:bnn/utils/colors.dart';
import 'package:bnn/utils/constants.dart';
import 'package:bnn/widgets/inputs/custom-input-field.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Suggested extends StatefulWidget {
  const Suggested({super.key});

  @override
  State<Suggested> createState() => _SuggestedState();
}

class _SuggestedState extends State<Suggested> {
  final supabase = Supabase.instance.client;

  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>>? data = Constants.fakeFollwers;
  String searchQuery = "";
  List<Map<String, dynamic>> filltered = [];

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    fetchdata();
  }

  Future<void> fetchdata() async {
    if (supabase.auth.currentUser != null) {
      final userId = supabase.auth.currentUser!.id;
      setState(() {
        _loading = true;
      });

      List<Map<String, dynamic>> res =
          await supabase.rpc('get_suggested_users', params: {
        'param_user_id': userId,
      });

      if (res.isNotEmpty) {
        for (int i = 0; i < res.length; i++) {
          final mutal = await supabase.rpc('get_count_mutual_friends',
              params: {'usera': userId, 'userb': res[i]["id"]});

          res[i]["mutal"] = '$mutal mutal friend';
          // res[i]["name"] = res[i]["first_name"] + res[i]["last_name"];
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

  Future<void> followUser(String followedId) async {
    final followerId = supabase.auth.currentUser!.id;
    removeUser(followedId);

    dynamic res = await supabase
        .from('relationships')
        .select()
        .eq('follower_id', followerId)
        .eq('followed_id', followedId)
        .or('status.eq.following, status.eq.friend');

    if (res.isNotEmpty) {
      CustomToast.showToastWarningTop(context, 'Already Followed!');

      return;
    }

    res = await supabase
        .from('relationships')
        .select()
        .eq('follower_id', followedId)
        .eq('followed_id', followerId)
        .or('status.eq.following, status.eq.friend');

    if (res.isNotEmpty) {
      CustomToast.showToastSuccessTop(context, 'Success');

      await supabase
          .from('relationships')
          .update({
            'status': 'friend',
          })
          .eq("follower_id", followedId)
          .eq("followed_id", followerId);

      await supabase.from('notifications').insert({
        'actor_id': followedId,
        'user_id': followerId,
        'action_type': 'follow'
      });

      return;
    }

    await supabase.from('relationships').upsert({
      'follower_id': followerId,
      'followed_id': followedId,
      'status': 'following',
    });

    await supabase.from('notifications').insert({
      'actor_id': followerId,
      'user_id': followedId,
      'action_type': 'follow'
    });

    // await fetchdata();
  }

  Future<void> removeUser(String userId) async {
    if (data != null) {
      for (int i = 0; i < data!.length; i++) {
        if (data![i]["id"] == userId) {
          setState(() {
            data!.removeAt(i);
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          child: Text(
            "Suggested",
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
                  onTap: () {},
                  child: Text(
                    'Suggested',
                    style: TextStyle(
                      color: Color(0xFF4D4C4A),
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
                  onTap: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => Friends()));
                  },
                  child: Text(
                    'Friends',
                    style: TextStyle(
                      color: Color(0x884D4C4A),
                      fontSize: 20,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            CustomInputField(
              placeholder: "Search for Suggested",
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
                if (value.isNotEmpty) {
                  final temp = data!
                      .where((item) =>
                          (item['username'] as String?)
                              ?.toLowerCase()
                              .contains(value.toLowerCase()) ??
                          false)
                      .toList();
                  filltered = temp;
                }
              },
              icon: Icons.search,
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
                          'Invite Suggested',
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
                          'Find Facebook Suggested',
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
              'Suggested accounts',
              style: TextStyle(
                color: Color(0xFF4D4C4A),
                fontSize: 15,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 10),
            if (data!.isNotEmpty)
              Expanded(
                child: Skeletonizer(
                  enabled: _loading,
                  enableSwitchAnimation: true,
                  child: ListView.builder(
                    // shrinkWrap: true,
                    itemCount:
                        searchQuery.isEmpty ? data!.length : filltered.length,
                    itemBuilder: (context, index) {
                      final item =
                          searchQuery.isEmpty ? data![index] : filltered[index];
                      return Container(
                        padding: EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () {},
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
                                    Text(
                                      item['username'],
                                      style: TextStyle(
                                        color: Color(0xFF4D4C4A),
                                        fontSize: 12,
                                        fontFamily: 'Nunito',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      item['mutal'] ?? "",
                                      style: TextStyle(
                                        color: Color(0xFF4D4C4A),
                                        fontFamily: "Poppins",
                                        fontSize: 9,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () async {
                                              followUser(item['id']);
                                            },
                                            child: Container(
                                              padding: EdgeInsets.only(
                                                  left: 8,
                                                  top: 2,
                                                  right: 8,
                                                  bottom: 2),
                                              decoration: BoxDecoration(
                                                gradient: _loading
                                                    ? null
                                                    : LinearGradient(
                                                        colors: [
                                                          AppColors
                                                              .primaryBlack,
                                                          AppColors.primaryRed,
                                                        ],
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                      ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                'Follow',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontFamily: 'Nunito',
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              removeUser(item["id"]);
                                            },
                                            child: Container(
                                              padding: EdgeInsets.only(
                                                  left: 8,
                                                  top: 2,
                                                  right: 8,
                                                  bottom: 2),
                                              decoration: _loading
                                                  ? null
                                                  : ShapeDecoration(
                                                      color: Color(0xFF4D4C4A),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                    ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                'Remove',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontFamily: 'Nunito',
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                  ],
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
