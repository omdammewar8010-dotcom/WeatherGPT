enum UserRole {
  citizen,
  fieldOfficer,
  authorityAdmin;

  String get id {
    switch (this) {
      case UserRole.citizen:
        return 'citizen';
      case UserRole.fieldOfficer:
        return 'field_officer';
      case UserRole.authorityAdmin:
        return 'authority_admin';
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.citizen:
        return 'Citizen';
      case UserRole.fieldOfficer:
        return 'Field Officer';
      case UserRole.authorityAdmin:
        return 'Authority / Admin';
    }
  }

  static UserRole fromString(String? role) {
    switch (role?.toLowerCase()) {
      case 'field_officer':
        return UserRole.fieldOfficer;
      case 'authority_admin':
      case 'admin':
        return UserRole.authorityAdmin;
      case 'citizen':
      default:
        return UserRole.citizen;
    }
  }
}

class UserEntity {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final UserRole role;
  final String state;
  final String district;
  final String? village;
  final String? badgeNumber; // For Field Officers / Authorities
  final String? token;
  final bool isDemoUser;

  const UserEntity({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.state,
    required this.district,
    this.village,
    this.badgeNumber,
    this.token,
    this.isDemoUser = false,
  });

  bool get isCitizen => role == UserRole.citizen;
  bool get isFieldOfficer => role == UserRole.fieldOfficer;
  bool get isAuthorityAdmin => role == UserRole.authorityAdmin;
}
