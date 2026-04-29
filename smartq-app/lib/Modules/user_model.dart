class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  
  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
    );
  }

  
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? role,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }
}