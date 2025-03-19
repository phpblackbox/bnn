import 'package:bnn/models/profiles_model.dart';
import 'package:bnn/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_supabase_chat_core/flutter_supabase_chat_core.dart';
import 'package:provider/provider.dart';

import '../class/user_ex.dart';
import '../utils/util.dart';

class UserTile extends StatefulWidget {
  final types.User user;
  final ValueChanged<types.User> onTap;

  const UserTile({
    super.key,
    required this.user,
    required this.onTap,
  });

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  ProfilesModel? userInfo;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);

      final result = await profileProvider.getUserProfileById(widget.user.id);
      if (mounted) {
        setState(() {
          userInfo = result;
        });
      }
    });
  }

  Widget _buildAvatar(types.User user) {
    final color = getAvatarColor(user.id);
    // final hasImage = user.imageUrl != null;
    // final name = user.getUserName();
    final hasImage = userInfo!.avatar != null;
    final name =
        '${userInfo!.firstName ?? ''} ${userInfo!.lastName ?? ''}'.trim();
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: UserOnlineStatusWidget(
        uid: user.id,
        builder: (status) => Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              backgroundColor: hasImage ? Colors.transparent : color,
              // backgroundImage: hasImage ? NetworkImage(user.imageUrl!) : null,
              backgroundImage:
                  hasImage ? NetworkImage(userInfo!.avatar!) : null,
              radius: 20,
              child: !hasImage
                  ? Text(
                      name.isEmpty ? '' : name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    )
                  : null,
            ),
            if (status == UserOnlineStatus.online)
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(right: 3, bottom: 3),
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return userInfo != null
        ? ListTile(
            leading: _buildAvatar(widget.user),
            title: Text(
                '${userInfo!.firstName ?? ''} ${userInfo!.lastName ?? ''}'
                    .trim()),
            onTap: () => widget.onTap(widget.user),
          )
        : Text('');
  }
}
