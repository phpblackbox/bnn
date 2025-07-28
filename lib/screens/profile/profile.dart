import 'dart:io';

import 'package:bnn/providers/auth_provider.dart';
import 'package:bnn/providers/profile_provider.dart';
import 'package:bnn/providers/post_provider.dart';
import 'package:bnn/screens/profile/following.dart';
import 'package:bnn/utils/colors.dart';
import 'package:bnn/widgets/buttons/button-gradient-main.dart';
import 'package:bnn/widgets/sub/bottom-navigation.dart';
import 'package:bnn/screens/post/posts.dart';
import 'package:bnn/screens/profile/followers.dart';
import 'package:bnn/screens/setting/edit.dart';
import 'package:bnn/screens/setting/settings.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final supabase = Supabase.instance.client;

  int _userorbookmark = 0;
  bool _hasAttemptedRefresh = false;

  PostProvider? _postProvider;

  @override
  void initState() {
    super.initState();
    // Store the provider reference when the widget is created
    _postProvider = Provider.of<PostProvider>(context, listen: false);
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);
      profileProvider.loading = true;
      _postProvider?.reset();
      await profileProvider.getCountsOfProfileInfo();
    });
  }

  void _onUserOrBookmark(int index) {
    setState(() {
      _userorbookmark = index;
    });
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    postProvider.reset();
  }

  @override
  void dispose() {
    // Tell the provider we're disposing to prevent notifications
    if (_postProvider != null) {
      _postProvider!.setDisposing(true);
      
      // Reset properties without triggering notifications
      _postProvider!.reset();
      
      // Reset flag (though it won't matter after disposal)
      _postProvider!.setDisposing(false);
    }
    
    // Always call super.dispose() last
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = Provider.of<AuthProvider>(context);

    // Loading state
    if (authProvider.isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    // Not logged in
    if (!authProvider.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Text("Please sign in")),
      );
    }

    // Profile not found - attempt to refresh
    if (authProvider.profile == null) {

      if (!_hasAttemptedRefresh) {
        _hasAttemptedRefresh = true; // Set flag to prevent further attempts

        Future.microtask(() async {
          try {
            // Try to refresh profile from API
            final success = await authProvider.refreshProfile();
            
            // Since we could be redirecting to another page, make sure this widget is still mounted
            if (!mounted) return;
            
            if (!success || authProvider.profile == null) {
              // If refresh fails, go to create profile
              CustomToast.showToastWarningTop(
                  context, "Please complete your profile setup");
              Navigator.pushReplacementNamed(context, '/create-profile');
            }
          } catch (e) {
            print('Error refreshing profile: $e');
            
            // Since we could be redirecting to another page, make sure this widget is still mounted
            if (!mounted) return;
            
            Navigator.pushReplacementNamed(context, '/create-profile');
          }
        });
      }

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("Profile Setup Required"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text(
                "Please complete your profile setup",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "You need to set up your profile before accessing this feature",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              SizedBox(height: 30),
              ButtonGradientMain(
                label: 'Set Up Profile',
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/create-profile');
                },
                textColor: Colors.white,
                gradientColors: [AppColors.primaryBlack, AppColors.primaryRed],
              ),
            ],
          ),
        ),
      );
    }

    _hasAttemptedRefresh = false;
    final meProfile = authProvider.profile!;
    final profileProvider = Provider.of<ProfileProvider>(context);
    final postProvider = Provider.of<PostProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (postProvider.currentContext != 'profile_${meProfile.id}' &&
        _userorbookmark == 0) {
      postProvider.reset();
      postProvider.loadPosts(userId: meProfile.id);
    } else if (postProvider.currentContext != 'bookmarks' &&
        _userorbookmark == 1) {
      postProvider.reset();
      postProvider.loadPosts(bookmark: true, currentUserId: meProfile.id);
    }
    });
    

    var currentTime;
    return WillPopScope(
      onWillPop: () {
        DateTime now = DateTime.now();
        if (currentTime == null ||
            now.difference(currentTime) > const Duration(seconds: 2)) {
          currentTime = now;
          CustomToast.showToastWarningTop(context, "Press agian to exit");
          return Future.value(false);
        } else {
          SystemNavigator.pop();
          exit(0);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Container(
              height: 330,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/profile/rect.png"),
                  fit: BoxFit.fill,
                ),
              ),
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 32, right: 16),
                    child: Row(
                      children: [
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Settings()));
                          },
                          child: Image(
                            image:
                                AssetImage('assets/images/icons/setting2.png'),
                            width: 32,
                            height: 32,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundImage: NetworkImage(meProfile.avatar!),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EditProfile()));
                          },
                          child: Image(
                            image: AssetImage('assets/images/icons/edit.png'),
                            width: 32,
                            height: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        meProfile.getFullName(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8),
                      // ImageIcon(
                      //   AssetImage(
                      //       'assets/images/icons/verified.png'),
                      //   size: 16,
                      //   color: Colors.white,
                      // ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    meProfile.username!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 10),
                  Skeletonizer(
                    enabled: profileProvider.loading,
                    enableSwitchAnimation: true,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Following()));
                          },
                          child: Column(
                            children: [
                              Text(
                                'Following',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                profileProvider.countFollowing.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          width: 1,
                          height: 47,
                          decoration: BoxDecoration(
                            color:
                                Colors.white.withOpacity(0.15000000596046448),
                          ),
                        ),
                        SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Followers()));
                          },
                          child: Column(
                            children: [
                              Text(
                                'Followers',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                profileProvider.countFollowers.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          width: 1,
                          height: 47,
                          decoration: BoxDecoration(
                            color:
                                Colors.white.withOpacity(0.15000000596046448),
                          ),
                        ),
                        SizedBox(width: 8),
                        Column(
                          children: [
                            Text(
                              'Views',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              profileProvider.countViews.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              )),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    _onUserOrBookmark(0);
                  },
                  child: ImageIcon(
                    AssetImage('assets/images/icons/all.png'),
                    color: _userorbookmark == 0
                        ? Colors.black
                        : Colors.black.withOpacity(0.5),
                    size: 24,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _onUserOrBookmark(1);
                  },
                  child: ImageIcon(
                    AssetImage('assets/images/icons/bookmark.png'),
                    color: _userorbookmark == 1
                        ? Colors.black.withOpacity(1)
                        : Colors.black.withOpacity(0.5),
                    size: 24,
                  ),
                ),
              ],
            ),
            if (_userorbookmark == 0) Posts(userId: meProfile.id),
            if (_userorbookmark == 1) Posts(bookmark: true),
          ],
        ),
        bottomNavigationBar: BottomNavigation(currentIndex: 4),
      ),
    );
  }
}
