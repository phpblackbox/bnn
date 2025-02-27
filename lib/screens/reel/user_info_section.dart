import 'package:bnn/models/profiles_model.dart';
import 'package:bnn/models/reel_model.dart';
import 'package:flutter/material.dart';

class UserInfoSection extends StatelessWidget {
  final ProfilesModel userInfo;
  final ReelModel reelInfo;

  const UserInfoSection(
      {Key? key, required this.userInfo, required this.reelInfo})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(userInfo.avatar!),
          backgroundColor: Colors.grey,
          radius: 20,
        ),
        const SizedBox(width: 10),
        Text(
          userInfo.username!,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 5),
        if (reelInfo.isFriend == false)
          GestureDetector(
            onTap: () async {
              // final meId = supabase.auth.currentUser!.id;

              // await supabase.from('relationships').upsert({
              //   'follower_id': meId,
              //   'followed_id': currentReel['author_id'],
              //   'status': 'following',
              // });

              // await supabase.from('notifications').insert({
              //   'actor_id': meId,
              //   'user_id': currentReel['author_id'],
              //   'action_type': 'follow'
              // });

              reelInfo.isFriend = true;
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 8.0),
              decoration: ShapeDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(35),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Follow',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
