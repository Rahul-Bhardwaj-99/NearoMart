/// Arguments for address-related navigation
class AddressArguments {
  final String addressId;
  final Map<String, dynamic>? addressData;
  final bool? isEditing;

  AddressArguments({
    required this.addressId,
    this.addressData,
    this.isEditing = false,
  });

  /// Create from address ID
  static AddressArguments fromId(String id) => AddressArguments(addressId: id);

  /// Create from full address data
  static AddressArguments fromData(Map<String, dynamic> data, {bool isEditing = false}) => AddressArguments(
    addressId: data['_id'] as String,
    addressData: data,
    isEditing: isEditing,
  );

  /// Serialize to map
  Map<String, dynamic> toMap() => {
    'addressId': addressId,
    'addressData': addressData,
    'isEditing': isEditing,
  };

  /// Deserialize from arguments
  static AddressArguments? fromGetArguments(dynamic args) {
    if (args == null) return null;
    if (args is AddressArguments) return args;
    if (args is String) return AddressArguments.fromId(args);
    if (args is Map<String, dynamic>) {
      return AddressArguments(
        addressId: args['addressId'] as String? ?? args['_id'] as String,
        addressData: args,
        isEditing: args['isEditing'] as bool? ?? false,
      );
    }
    return null;
  }
}
