/// Arguments for profile edit navigation
class EditProfileArguments {
  final String? name;
  final String? phone;
  final String? email;
  final String? profilePic;

  EditProfileArguments({
    this.name,
    this.phone,
    this.email,
    this.profilePic,
  });

  /// Create from user data map
  static EditProfileArguments fromUserData(Map<String, dynamic> data) => EditProfileArguments(
    name: data['name'] as String?,
    phone: data['phone'] as String?,
    email: data['email'] as String?,
    profilePic: data['profilePic'] as String?,
  );

  /// Serialize to map
  Map<String, dynamic> toMap() => {
    'name': name,
    'phone': phone,
    'email': email,
    'profilePic': profilePic,
  };

  /// Deserialize from arguments
  static EditProfileArguments? fromGetArguments(dynamic args) {
    if (args == null) return null;
    if (args is EditProfileArguments) return args;
    if (args is Map<String, dynamic>) {
      return EditProfileArguments(
        name: args['name'] as String?,
        phone: args['phone'] as String?,
        email: args['email'] as String?,
        profilePic: args['profilePic'] as String?,
      );
    }
    return null;
  }
}
