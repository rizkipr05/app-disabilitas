class User {
  final int id;
  final String username;
  final String role;
  final String fullName;

  final String? profileImage;

  User({
    required this.id,
    required this.username,
    required this.role,
    required this.fullName,
    this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.parse(json['id'].toString()),
      username: json['username'],
      role: json['role'],
      fullName: json['full_name'],
      profileImage: json['profile_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'role': role,
      'full_name': fullName,
    };
  }
}
