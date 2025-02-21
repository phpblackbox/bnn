class StoryModel {
  final List<dynamic> imgUrls;
  final String id;
  final String username;
  final String avatar;
  final String authorId;
  final String createdAt;
  final String comments;
  final String timeDiff;
  final dynamic profiles;

  StoryModel({
    required this.imgUrls,
    required this.id,
    required this.username,
    required this.avatar,
    required this.authorId,
    required this.createdAt,
    required this.comments,
    required this.timeDiff,
    required this.profiles,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      imgUrls: json['img_urls'] ?? [],
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      avatar: json['avatar'] ?? '',
      authorId: json['author_id'] ?? '',
      createdAt: json['created_at'] ?? '',
      comments: json['comments'] ?? '',
      timeDiff: json['timeDiff'] ?? '',
      profiles: json['profiles'] ?? {},
    );
  }
}
