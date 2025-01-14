class Profiles {
  final String id;
  late String firstName;
  late String lastName;
  late String username;
  late String? bio;
  late int age;
  late int gender;
  late List<String>? interests;
  late String avatar;
  late DateTime? createdAt;

  // Constructor
  Profiles({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    this.bio,
    required this.age,
    required this.gender,
    required this.avatar,
    this.interests,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Method to convert User object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'bio': bio,
      'age': age,
      'gender': gender,
      'avatar': avatar,
      'interests': interests,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Factory method to create a User object from JSON
  factory Profiles.fromJson(Map<String, dynamic> json) {
    return Profiles(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      username: json['username'],
      bio: json['bio'],
      gender: json['gender'],
      avatar: json['avatar'],
      interests: json['interests'],
      age: json['avatar'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // Method to get full name
  String getFullName() {
    return '$firstName $lastName';
  }
}
