/// Personal information model for secure storage
class PersonalInfo {
  final String? fullName;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? address;
  final Map<String, String>? customFields;

  const PersonalInfo({
    this.fullName,
    this.phoneNumber,
    this.dateOfBirth,
    this.address,
    this.customFields,
  });

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'phoneNumber': phoneNumber,
    'dateOfBirth': dateOfBirth?.toIso8601String(),
    'address': address,
    'customFields': customFields,
  };

  factory PersonalInfo.fromJson(Map<String, dynamic> json) => PersonalInfo(
    fullName: json['fullName'] as String?,
    phoneNumber: json['phoneNumber'] as String?,
    dateOfBirth: json['dateOfBirth'] != null
        ? DateTime.parse(json['dateOfBirth'] as String)
        : null,
    address: json['address'] as String?,
    customFields: json['customFields'] != null
        ? Map<String, String>.from(json['customFields'] as Map)
        : null,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PersonalInfo &&
        other.fullName == fullName &&
        other.phoneNumber == phoneNumber &&
        other.dateOfBirth == dateOfBirth &&
        other.address == address &&
        _mapEquals(other.customFields, customFields);
  }

  @override
  int get hashCode {
    return fullName.hashCode ^
        phoneNumber.hashCode ^
        dateOfBirth.hashCode ^
        address.hashCode ^
        customFields.hashCode;
  }

  @override
  String toString() {
    return 'PersonalInfo(fullName: $fullName, phoneNumber: $phoneNumber, dateOfBirth: $dateOfBirth, address: $address, customFields: $customFields)';
  }

  bool _mapEquals(Map<String, String>? a, Map<String, String>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}