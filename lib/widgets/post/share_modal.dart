import 'package:bnn/providers/post_provider.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:bnn/providers/profile_provider.dart';
import 'package:bnn/providers/auth_provider.dart';
import 'package:bnn/screens/chat/room.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_supabase_chat_core/flutter_supabase_chat_core.dart';

class ShareModal extends StatefulWidget {
  final dynamic post;
  final String type;

  const ShareModal({
    super.key,
    required this.post,
    required this.type,
  });

  @override
  _ShareModalState createState() => _ShareModalState();
}

class _ShareModalState extends State<ShareModal> {
  List<dynamic> friends = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    final friendsList = await profileProvider.getFriends();
    setState(() {
      friends = friendsList;
      isLoading = false;
    });
  }

  Future<void> _sendDM(BuildContext context, dynamic friend) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final meId = authProvider.user?.id;

    if (friend['id'] == meId) {
      CustomToast.showToastWarningTop(
          context, "You can't send message yourself");
      return;
    }

    // Check if already shared
    final postProvider = Provider.of<PostProvider>(context, listen: false);

    final postId = widget.type == "post" ? widget.post['id'] : widget.post;

    final hasShared = await postProvider.hasSharedPost(
      postId,
      meId!,
      friend['id'],
    );

    if (hasShared) {
      CustomToast.showToastWarningTop(context,
          "You have already shared this post to ${friend['first_name']}");
      return;
    }
    final share = await postProvider.addShare(
      postId,
      meId,
      friend['id'],
      widget.type,
    );

    if (share == null) {
      CustomToast.showToastWarningTop(context, "Failed to share post");
      return;
    }

    types.User otherUser = types.User(
      id: friend['id'],
      firstName: friend['first_name'],
      lastName: friend['last_name'],
      imageUrl: friend['avatar'],
    );

    final navigator = Navigator.of(context);
    final temp = await SupabaseChatCore.instance.createRoom(otherUser);

    var room = temp.copyWith(
      imageUrl: friend['avatar'],
      name: "${friend['first_name']} ${friend['last_name']}",
    );

    final message = types.PartialText(
      text: "Check out this ${widget.type == "post" ? "post" : "9:16s"}",
      metadata: {
        'post_id': postId,
        'type': widget.type,
      },
    );

    await SupabaseChatCore.instance.sendMessage(message, room.id);

    navigator.pop(); // Close share modal
    await navigator.push(
      MaterialPageRoute(
        builder: (context) => RoomPage(room: room),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Share with Friends',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (friends.isEmpty)
            const Center(
              child: Text('No friends found'),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  final friend = friends[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(friend['avatar']),
                    ),
                    title:
                        Text('${friend['first_name']} ${friend['last_name']}'),
                    subtitle: Text(friend['username'] ?? ''),
                    onTap: () => _sendDM(context, friend),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
