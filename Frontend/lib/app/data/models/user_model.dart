class UserModel {
  final String id;
  final String? name;
  final String phone;
  final String? email;
  final String? profilePic;
  final bool? isVerified;
  final bool? isOnboarded;
  final String? role;

  UserModel({
    required this.id,
    this.name,
    required this.phone,
    this.email,
    this.profilePic,
    this.isVerified,
    this.isOnboarded,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'],
      phone: json['phone'] ?? '',
      email: json['email'],
      profilePic: json['profilePic'],
      isVerified: json['isVerified'],
      isOnboarded: json['isOnboarded'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'profilePic': profilePic,
    'isVerified': isVerified,
    'isOnboarded': isOnboarded,
    'role': role,
  };

  UserModel copyWith({
    String? name,
    String? email,
    String? profilePic,
    bool? isVerified,
    bool? isOnboarded,
    String? role,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      phone: phone,
      email: email ?? this.email,
      profilePic: profilePic ?? this.profilePic,
      isVerified: isVerified ?? this.isVerified,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      role: role ?? this.role,
    );
  }
}
