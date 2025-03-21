class UserModel {
  final String? id;
  final String? email;

  UserModel({this.id, this.email});

  factory UserModel.fromSupabase(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'],
      email: data['email'],
    );
  }
}
