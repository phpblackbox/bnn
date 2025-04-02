import 'package:bnn/models/profiles_model.dart';
import 'package:bnn/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_supabase_chat_core/flutter_supabase_chat_core.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../class/message_status_ex.dart';
import '../utils/util.dart';

class RoomTile extends StatefulWidget {
  final types.Room room;
  final ValueChanged<types.Room> onTap;

  const RoomTile({
    super.key,
    required this.room,
    required this.onTap,
  });

  @override
  State<RoomTile> createState() => _RoomTileState();
}

class _RoomTileState extends State<RoomTile> {
  ProfilesModel? userInfo;
  types.User? otherUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);

      var otherUserIndex = -1;
      types.User? otherUser;

      if (widget.room.type == types.RoomType.direct) {
        otherUserIndex = widget.room.users.indexWhere(
          (u) => u.id != SupabaseChatCore.instance.loggedSupabaseUser!.id,
        );
        if (otherUserIndex >= 0) {
          otherUser = widget.room.users[otherUserIndex];
        }
      }
      final userId = otherUser!.id;
      final result = await profileProvider.getUserProfileById(userId);

      if (mounted) {
        setState(() {
          userInfo = result;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
            padding: const EdgeInsets.all(4),
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black,
                  Color(0xFF800000),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              key: ValueKey(widget.room.id),
              leading: userInfo != null ? _buildAvatar(widget.room) : Text(''),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  userInfo != null ? Text(
                    '${userInfo!.firstName ?? ''} ${userInfo!.lastName ?? ''}'
                                .trim()
                                .length >
                            16
                        ? '${('${userInfo!.firstName ?? ''} ${userInfo!.lastName ?? ''}').trim().substring(0, 16)}...'
                        : '${userInfo!.firstName ?? ''} ${userInfo!.lastName ?? ''}'
                            .trim(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.80,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                  ) : Text(''),
                  if (widget.room.lastMessages?.isNotEmpty == true)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          timeago.format(
                            DateTime.now().subtract(
                              Duration(
                                milliseconds:
                                    DateTime.now().millisecondsSinceEpoch -
                                        (widget.room.updatedAt ?? 0),
                              ),
                            ),
                            locale: 'en_short',
                          ),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        if (widget.room.lastMessages!.first.status != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Icon(
                              size: 20,
                              widget.room.lastMessages!.first.status!.icon,
                              color: widget.room.lastMessages!.first.status ==
                                      types.Status.seen
                                  ? Color(0XFFF30802)
                                  : Color(0XFFF30802),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
              subtitle: widget.room.lastMessages?.isNotEmpty == true &&
                      widget.room.lastMessages!.first is types.TextMessage
                  ? Text(
                      (widget.room.lastMessages!.first as types.TextMessage)
                          .text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12.80,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                    )
                  : null,
              onTap: () => widget.onTap(widget.room),
            ),
          );
  }

  Widget _buildAvatar(types.Room room) {
    final color = getAvatarColor(room.id);
    

    final hasImage = userInfo!.avatar != null;
    final name = room.name ?? userInfo!.firstName;

    final Widget child = CircleAvatar(
      backgroundColor: hasImage ? Colors.transparent : color,
      backgroundImage: hasImage ? NetworkImage(userInfo!.avatar!) : null,
      radius: 25,
      child: !hasImage
          ? Text(
              name!.isEmpty ? '' : name[0].toUpperCase(),
              style: const TextStyle(color: Colors.white),
            )
          : null,
    );
    if (otherUser == null) {
      return Padding(
        padding: const EdgeInsets.only(right: 6),
        child: child,
      );
    }
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: UserOnlineStatusWidget(
        uid: otherUser!.id,
        builder: (status) => Stack(
          alignment: Alignment.bottomRight,
          children: [
            child,
            if (status == UserOnlineStatus.online)
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(
                  right: 3,
                  bottom: 3,
                ),
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
}
