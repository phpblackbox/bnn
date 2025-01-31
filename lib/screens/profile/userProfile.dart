import 'package:bnn/main.dart';
import 'package:bnn/screens/chat/room.dart';
import 'package:bnn/screens/home/postView.dart';
import 'package:bnn/screens/profile/ProfileFollower.dart';
import 'package:bnn/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_supabase_chat_core/flutter_supabase_chat_core.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class UserProfile extends StatefulWidget {
  final String userId;

  const UserProfile({
    super.key,
    required this.userId,
  });
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final dynamic data = {
    "username": "John\nSmith",
    "posts": 35,
    "followers": 6552,
    "views": 128,
    "about":
        "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s",
    "year": "20yrs",
    "marital": "Married",
    "nationality": "African-American",
    "location": "United States, California",
    "content": "Content Creator",
  };

  bool _loading = true;

  @override
  void initState() {
    super.initState();

    fetchdata();
    updateViewPlus();
  }

  void updateViewPlus() async {
    await supabase.rpc('increment_profile_view_count', params: {
      'user_id': widget.userId,
    });
  }

  void fetchdata() async {
    setState(() {
      _loading = true;
    });
    final userInfo = await supabase
        .from('profiles')
        .select()
        .eq("id", widget.userId)
        .single();

    if (userInfo.isNotEmpty) {
      int followers = await supabase.rpc('get_count_follower', params: {
            'param_followed_id': widget.userId,
          }) ??
          0;

      int posts = await supabase.rpc('get_count_posts', params: {
            'param_user_id': widget.userId,
          }) ??
          0;

      setState(() {
        data["username"] =
            "${userInfo["first_name"]}\n${userInfo["last_name"]}";
        data["followers"] = followers;
        data["posts"] = posts;
        data["id"] = userInfo["id"];
        data["first_name"] = userInfo["first_name"];
        data["last_name"] = userInfo["last_name"];
        data["avatar"] = userInfo["avatar"];
        data["views"] = userInfo["views"];
        data["bio"] = userInfo["bio"];
        data["age"] = '${userInfo["age"]}yrs';
      });
    }
    setState(() {
      _loading = false;
    });
  }

  String formatWithCommas(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  void message() async {
    final meId = supabase.auth.currentUser!.id;
    if (data['id'] == meId) {
      CustomToast.showToastWarningTop(context, "You can't send message to you");
      return;
    }

    types.User otherUser = types.User(
      id: data['id'],
      firstName: data['first_name'],
      lastName: data['last_name'],
      imageUrl: data['avatar'],
    );

    final navigator = Navigator.of(context);
    final temp = await SupabaseChatCore.instance.createRoom(otherUser);

    var room = temp.copyWith(
        imageUrl: data['avatar'],
        name: "${data['first_name']} ${data['last_name']}");

    navigator.pop();

    await navigator.push(
      MaterialPageRoute(
        builder: (context) => RoomPage(room: room),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: _loading
              ? Center(child: CircularProgressIndicator())
              : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          children: [
                            Stack(
                              children: <Widget>[
                                Container(
                                  width: double.infinity,
                                  height: 350,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image: NetworkImage(data["avatar"]),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 350,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    gradient: LinearGradient(
                                      begin: FractionalOffset.topCenter,
                                      end: FractionalOffset.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.white.withOpacity(1),
                                      ],
                                      stops: [0.5, 1.0],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: IconButton(
                                    icon: Icon(Icons.close,
                                        color: Color(0xFF4D4C4A)),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 8,
                                  child: Skeletonizer(
                                    enabled: _loading,
                                    enableSwitchAnimation: true,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Text(
                                          data["username"],
                                          style: TextStyle(
                                            color: Color(0xFF4D4C4A),
                                            fontSize: 26,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w400,
                                            height: 1.06,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                        SizedBox(width: 5, height: 15),
                                        ImageIcon(
                                          AssetImage(
                                              'assets/images/icons/verified.png'),
                                          color: Colors.red,
                                          size: 16.0,
                                        ),
                                        SizedBox(width: 35),
                                        Row(children: [
                                          Column(
                                            children: [
                                              Text(
                                                'Posts',
                                                style: TextStyle(
                                                  color: Color(0xFF4D4C4A),
                                                  fontSize: 14,
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                data["posts"].toString(),
                                                style: TextStyle(
                                                  color: Color(0xFF4D4C4A),
                                                  fontSize: 20,
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              )
                                            ],
                                          ),
                                          SizedBox(width: 10),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ProfileFollowers(
                                                            userId: data["id"],
                                                          )));
                                            },
                                            child: Column(
                                              children: [
                                                Text(
                                                  'Followers',
                                                  style: TextStyle(
                                                    color: Color(0xFF4D4C4A),
                                                    fontSize: 14,
                                                    fontFamily: 'Poppins',
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                SizedBox(height: 10),
                                                Text(
                                                  formatWithCommas(
                                                          data["followers"])
                                                      .toString(),
                                                  style: TextStyle(
                                                    color: Color(0xFF4D4C4A),
                                                    fontSize: 20,
                                                    fontFamily: 'Poppins',
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Column(
                                            children: [
                                              Text(
                                                'Views',
                                                style: TextStyle(
                                                  color: Color(0xFF4D4C4A),
                                                  fontSize: 14,
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                data["views"].toString(),
                                                style: TextStyle(
                                                  color: Color(0xFF4D4C4A),
                                                  fontSize: 20,
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              )
                                            ],
                                          ),
                                          SizedBox(width: 10),
                                        ]),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // about and ...
                    Container(
                      padding: EdgeInsets.all(8),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 8),
                                Text(
                                  'ABOUT',
                                  style: TextStyle(
                                    color: Color(0xFF4D4C4A),
                                    fontSize: 14,
                                    fontFamily: 'Abel',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  data['bio'],
                                  style: TextStyle(
                                    color: Color(0xFF4D4C4A),
                                    fontSize: 12,
                                    fontFamily: 'Abel',
                                    fontWeight: FontWeight.w400,
                                    height: 1.50,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        ImageIcon(
                                          AssetImage(
                                              'assets/images/icons/speedometer.png'),
                                          size: 22.0,
                                          color: Color(0xFF4D4C4A),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          data["age"],
                                          style: TextStyle(
                                            color: Color(0xFF4D4C4A),
                                            fontSize: 12,
                                            fontFamily: 'Abel',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        ImageIcon(
                                          AssetImage(
                                              'assets/images/icons/heart.png'),
                                          size: 22.0,
                                          color: Color(0xFF4D4C4A),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          data["marital"],
                                          style: TextStyle(
                                            color: Color(0xFF4D4C4A),
                                            fontSize: 12,
                                            fontFamily: 'Abel',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        ImageIcon(
                                          AssetImage(
                                              'assets/images/icons/flag.png'),
                                          size: 22.0,
                                          color: Color(0xFF4D4C4A),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          data["nationality"],
                                          style: TextStyle(
                                            color: Color(0xFF4D4C4A),
                                            fontSize: 12,
                                            fontFamily: 'Abel',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        ImageIcon(
                                          AssetImage(
                                              'assets/images/icons/location.png'),
                                          size: 22.0,
                                          color: Color(0xFF4D4C4A),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          data["location"],
                                          style: TextStyle(
                                            color: Color(0xFF4D4C4A),
                                            fontSize: 12,
                                            fontFamily: 'Abel',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        ImageIcon(
                                          AssetImage(
                                              'assets/images/icons/content.png'),
                                          size: 22.0,
                                          color: Color(0xFF4D4C4A),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          data["content"],
                                          style: TextStyle(
                                            color: Color(0xFF4D4C4A),
                                            fontSize: 12,
                                            fontFamily: 'Abel',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                        onTap: message,
                                        child: Image.asset(
                                          'assets/images/profile_msg_btn.png',
                                          width: 75,
                                          height: 75,
                                        )),
                                  ],
                                )
                              ],
                            ),
                          ]),
                    ),

                    // Posts
                    Padding(
                      padding: EdgeInsets.only(left: 16, top: 0, right: 16),
                      child: PostView(userId: widget.userId),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
