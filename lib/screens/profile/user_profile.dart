import 'dart:io';
import 'package:bnn/providers/user_profile_provider.dart';
import 'package:bnn/screens/chat/room.dart';
import 'package:bnn/screens/home/posts.dart';
import 'package:bnn/screens/profile/user_follower.dart';
import 'package:bnn/screens/profile/user_following.dart';
import 'package:bnn/utils/constants.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_supabase_chat_core/flutter_supabase_chat_core.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:supabase_flutter/supabase_flutter.dart';

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProfileProvider =
          Provider.of<UserProfileProvider>(context, listen: false);
      userProfileProvider.loading = true;
      await userProfileProvider.getCountsOfProfileInfo(widget.userId);
      await userProfileProvider.increaseUserView(widget.userId);
    });
  }

  void message() async {
    final supabase = Supabase.instance.client;
    final meId = supabase.auth.currentUser!.id;
    final userInfo =
        Provider.of<UserProfileProvider>(context, listen: false).userInfo!;
    if (userInfo.id == meId) {
      CustomToast.showToastWarningTop(context, "You can't send message to you");
      return;
    }

    types.User otherUser = types.User(
      id: userInfo.id!,
      firstName: userInfo.firstName,
      lastName: userInfo.lastName,
      imageUrl: userInfo.avatar,
    );

    final navigator = Navigator.of(context);
    final temp = await SupabaseChatCore.instance.createRoom(otherUser);

    var room = temp.copyWith(
        imageUrl: userInfo.avatar,
        name: "${userInfo.firstName} ${userInfo.lastName}");

    navigator.pop();

    await navigator.push(
      MaterialPageRoute(
        builder: (context) => RoomPage(room: room),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProfileProvider = Provider.of<UserProfileProvider>(context);

    return Scaffold(
      body: userProfileProvider.loading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Column(children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: <Widget>[
                          Container(
                            width: double.infinity,
                            height: 280,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                    userProfileProvider.userInfo!.avatar!),
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: 280,
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
                            top: Platform.isIOS ? 40 : 12,
                            child: IconButton(
                              icon: Icon(Icons.close, color: Color(0xFF4D4C4A)),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 10,
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UserFollowing(
                                          userId:
                                              userProfileProvider.userInfo!.id!,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Text(
                                        'Following',
                                        style: TextStyle(
                                          color: Color(0xFF4D4C4A),
                                          fontSize: 12,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        Constants().formatWithCommas(
                                            userProfileProvider.countFollowing),
                                        style: TextStyle(
                                          color: Color(0xFF4D4C4A),
                                          fontSize: 16,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UserFollowers(
                                          userId:
                                              userProfileProvider.userInfo!.id!,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Text(
                                        'Followers',
                                        style: TextStyle(
                                          color: Color(0xFF4D4C4A),
                                          fontSize: 12,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        Constants().formatWithCommas(
                                            userProfileProvider.countFollowers),
                                        style: TextStyle(
                                          color: Color(0xFF4D4C4A),
                                          fontSize: 16,
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
                                        fontSize: 12,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      Constants().formatWithCommas(
                                          userProfileProvider.countViews),
                                      style: TextStyle(
                                        color: Color(0xFF4D4C4A),
                                        fontSize: 16,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 8,
                            child: Skeletonizer(
                              enabled: userProfileProvider.loading,
                              enableSwitchAnimation: true,
                              child: Text(
                                '${userProfileProvider.userInfo!.firstName!}\n${userProfileProvider.userInfo!.lastName!}',
                                style: TextStyle(
                                  color: Color(0xFF4D4C4A),
                                  fontSize: 20,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w400,
                                  height: 1.06,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 8),
                                        Text(
                                          'ABOUT',
                                          style: TextStyle(
                                            color: Color(0xFF4D4C4A),
                                            fontSize: 16,
                                            fontFamily: 'Abel',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.7,
                                          child: Text(
                                            userProfileProvider.userInfo!.bio!,
                                            style: TextStyle(
                                              color: Color(0xFF4D4C4A),
                                              fontSize: 12,
                                              fontFamily: 'Abel',
                                              fontWeight: FontWeight.w400,
                                              height: 1.50,
                                            ),
                                            maxLines: 15,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                              userProfileProvider.userInfo!.age
                                                  .toString(),
                                              style: TextStyle(
                                                color: Color(0xFF4D4C4A),
                                                fontSize: 12,
                                                fontFamily: 'Abel',
                                                fontWeight: FontWeight.w400,
                                              ),
                                            )
                                          ],
                                        ),
                                        // SizedBox(height: 4),
                                        // Row(
                                        //   children: [
                                        //     ImageIcon(
                                        //       AssetImage(
                                        //           'assets/images/icons/heart.png'),
                                        //       size: 22.0,
                                        //       color: Color(0xFF4D4C4A),
                                        //     ),
                                        //     SizedBox(width: 8),
                                        //     Text(
                                        //       data["marital"],
                                        //       style: TextStyle(
                                        //         color: Color(0xFF4D4C4A),
                                        //         fontSize: 12,
                                        //         fontFamily: 'Abel',
                                        //         fontWeight: FontWeight.w400,
                                        //       ),
                                        //     )
                                        //   ],
                                        // ),
                                        // SizedBox(height: 4),
                                        // Row(
                                        //   children: [
                                        //     ImageIcon(
                                        //       AssetImage(
                                        //           'assets/images/icons/flag.png'),
                                        //       size: 22.0,
                                        //       color: Color(0xFF4D4C4A),
                                        //     ),
                                        //     SizedBox(width: 8),
                                        //     Text(
                                        //       data["nationality"],
                                        //       style: TextStyle(
                                        //         color: Color(0xFF4D4C4A),
                                        //         fontSize: 12,
                                        //         fontFamily: 'Abel',
                                        //         fontWeight: FontWeight.w400,
                                        //       ),
                                        //     )
                                        //   ],
                                        // ),
                                        // SizedBox(height: 4),
                                        // Row(
                                        //   children: [
                                        //     ImageIcon(
                                        //       AssetImage(
                                        //           'assets/images/icons/location.png'),
                                        //       size: 22.0,
                                        //       color: Color(0xFF4D4C4A),
                                        //     ),
                                        //     SizedBox(width: 8),
                                        //     Text(
                                        //       data["location"],
                                        //       style: TextStyle(
                                        //         color: Color(0xFF4D4C4A),
                                        //         fontSize: 12,
                                        //         fontFamily: 'Abel',
                                        //         fontWeight: FontWeight.w400,
                                        //       ),
                                        //     )
                                        //   ],
                                        // ),
                                        // SizedBox(height: 4),
                                        // Row(
                                        //   children: [
                                        //     ImageIcon(
                                        //       AssetImage(
                                        //           'assets/images/icons/content.png'),
                                        //       size: 22.0,
                                        //       color: Color(0xFF4D4C4A),
                                        //     ),
                                        //     SizedBox(width: 8),
                                        //     Text(
                                        //       data["content"],
                                        //       style: TextStyle(
                                        //         color: Color(0xFF4D4C4A),
                                        //         fontSize: 12,
                                        //         fontFamily: 'Abel',
                                        //         fontWeight: FontWeight.w400,
                                        //       ),
                                        //     )
                                        //   ],
                                        // )
                                      ],
                                    ),
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
                              ])
                        ]),
                  ),
                ]),
                Posts(userId: widget.userId)
              ],
            ),
    );
  }
}
