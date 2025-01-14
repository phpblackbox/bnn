import 'package:bnn/main.dart';
import 'package:bnn/screens/signup/ButtonGradientMain.dart';
import 'package:flutter/material.dart';
import 'package:bnn/screens/signup/CustomInputField.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_supabase_chat_core/flutter_supabase_chat_core.dart';

class Followers extends StatefulWidget {
  const Followers({super.key});

  @override
  State<Followers> createState() => _FollowersState();
}

class _FollowersState extends State<Followers> {
  final TextEditingController searchController = TextEditingController();

  List<dynamic>? data = [];
  bool _loading = true;

  void initState() {
    super.initState();

    fetchData();
  }

  Future<void> followUser(String followerId) async {
    final followedId = supabase.auth.currentUser!.id;

    await supabase
        .from('relationships')
        .update({
          'status': 'friend',
        })
        .eq("follower_id", followerId)
        .eq("followed_id", followedId);

    fetchData();
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
      setState(() {
        data = res;
      });

      for (int i = 0; i < data!.length; i++) {
        final mutal = await supabase.rpc('get_count_mutual_friends',
            params: {'usera': userId, 'userb': data![i]["id"]});

        setState(() {
          data![i]["mutal"] = '${mutal} mutal friend';
          data![i]["name"] = data![i]["first_name"] + data![i]["last_name"];
        });
      }

      setState(() {
        _loading = false;
      });
    } else {
      setState(() {
        data = [];
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
            if (data!.length > 0)
              Container(
                child: Skeletonizer(
                  enabled: _loading,
                  enableSwitchAnimation: true,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: data!.length,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () {},
                          child: Row(
                            children: [
                              Image.network(
                                data![index]['avatar'],
                                fit: BoxFit.fill,
                                width: 50,
                                height: 50,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data![index]['name'] ?? "",
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
                              SizedBox(width: 40),
                              Expanded(
                                child: ButtonGradientMain(
                                  label: 'Follow',
                                  onPressed: () {
                                    followUser(data![index]['id']);
                                  },
                                  textColor: Colors.white,
                                  gradientColors: [
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
                ),
              ),
          ],
        ),
      ),
    );
  }
}
