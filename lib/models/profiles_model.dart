class ProfilesModel {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? username;
  final int? age;
  final String? bio;
  final int? gender;
  final String? avatar;

  ProfilesModel(
    this.id, {
    this.firstName,
    this.lastName,
    this.username,
    this.age,
    this.bio,
    this.gender,
    this.avatar,
  });

  factory ProfilesModel.fromJson(Map<String, dynamic> data) {
    return ProfilesModel(
      data['id'],
      firstName: data['first_name'],
      lastName: data['last_name'],
      username: data['username'],
      age: data['age'],
      bio: data['bio'],
      gender: data['gender'],
      avatar: data['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'age': age,
      'bio': bio,
      'gender': gender,
      'avatar': avatar,
    };
  }

  String getFullName() {
    if (firstName == null && lastName == null) return 'Anonymous User';
    if (firstName == null) return lastName ?? '';
    if (lastName == null) return firstName ?? '';
    return '$firstName $lastName';
  }

  ProfilesModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? username,
    int? age,
    String? bio,
    int? gender,
    String? avatar,
  }) {
    return ProfilesModel(
      id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      age: age ?? this.age,
      bio: bio ?? this.bio,
      gender: gender ?? this.gender,
      avatar: avatar ?? this.avatar,
    );
  }
}
