import 'dart:io';
import 'package:bnn/providers/user_profile_provider.dart';
import 'package:bnn/screens/chat/room.dart';
import 'package:bnn/screens/post/posts.dart';
import 'package:bnn/screens/profile/user_follower.dart';
import 'package:bnn/screens/profile/user_following.dart';
import 'package:bnn/screens/profile/user_profile_info.dart';
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
  bool _isProfileLoaded = false;

  @override
  void initState() {
    _isProfileLoaded = false;
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProfileProvider =
          Provider.of<UserProfileProvider>(context, listen: false);
      userProfileProvider.loading = true;
      await userProfileProvider.getCountsOfProfileInfo(widget.userId);
      await userProfileProvider.increaseUserView(widget.userId);
      if (mounted) {
        setState(() {
          _isProfileLoaded = true;
        });
      }
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

    if (!_isProfileLoaded || userProfileProvider.loading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          UserProfileInfo(
            key: ValueKey('profile_${widget.userId}'),
            onMessageTap: message,
          ),
          Posts(
            key: ValueKey('posts_${widget.userId}'),
            userId: widget.userId,
          )
        ],
      ),
    );
  }
}
