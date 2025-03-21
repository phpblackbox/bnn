import 'package:bnn/models/profiles_model.dart';

class ReelModel {
  final int id;
  final String videoUrl;
  final String authorId;
  ProfilesModel? userInfo;
  int likes;
  int bookmarks;
  int comments;
  int share;
  bool isFriend;

  ReelModel({
    required this.id,
    required this.videoUrl,
    required this.authorId,
    this.userInfo,
    this.likes = 0,
    this.bookmarks = 0,
    this.comments = 0,
    this.share = 0,
    this.isFriend = false,
  });

  factory ReelModel.fromJson(Map<String, dynamic> json) {
    return ReelModel(
      id: json['id'],
      videoUrl: json['video_url'],
      authorId: json['author_id'],
    );
  }
}
