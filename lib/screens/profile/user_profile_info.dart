import 'dart:io';
import 'package:bnn/providers/user_profile_provider.dart';
import 'package:bnn/screens/profile/user_follower.dart';
import 'package:bnn/screens/profile/user_following.dart';
import 'package:bnn/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class UserProfileInfo extends StatelessWidget {
  final VoidCallback onMessageTap;

  const UserProfileInfo({
    Key? key,
    required this.onMessageTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProfileProvider = Provider.of<UserProfileProvider>(context);

    return Column(
      children: [
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
                      image:
                          NetworkImage(userProfileProvider.userInfo!.avatar!),
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
                                userId: userProfileProvider.userInfo!.id!,
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
                                userId: userProfileProvider.userInfo!.id!,
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                            width: MediaQuery.of(context).size.width * 0.7,
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
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: onMessageTap,
                        child: Image.asset(
                          'assets/images/profile_msg_btn.png',
                          width: 75,
                          height: 75,
                        ),
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
