import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.phone,
    required super.role,
    required super.state,
    required super.district,
    super.village,
    super.badgeNumber,
    super.token,
    super.isDemoUser = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? json['uid'] as String? ?? 'usr_demo',
      fullName: json['fullName'] as String? ?? json['full_name'] as String? ?? 'Citizen User',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: UserRole.fromString(json['role'] as String?),
      state: json['state'] as String? ?? 'Arunachal Pradesh',
      district: json['district'] as String? ?? 'Tawang',
      village: json['village'] as String?,
      badgeNumber: json['badgeNumber'] as String? ?? json['badge_number'] as String?,
      token: json['token'] as String? ?? json['access_token'] as String?,
      isDemoUser: json['isDemoUser'] as bool? ?? json['is_demo_user'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role.id,
      'state': state,
      'district': district,
      'village': village,
      'badgeNumber': badgeNumber,
      'token': token,
      'isDemoUser': isDemoUser,
    };
  }

  // Pre-configured Judge Evaluation Demo Profiles
  static UserModel get demoCitizen => const UserModel(
        id: 'demo_citizen_001',
        fullName: 'Ayush Sharma',
        email: 'ayush.citizen@ner-guard.in',
        phone: '+91 98765 43210',
        role: UserRole.citizen,
        state: 'Arunachal Pradesh',
        district: 'Tawang',
        village: 'Lumla Sector 3',
        token: 'mock_jwt_citizen_token_sih2026',
        isDemoUser: true,
      );

  static UserModel get demoOfficer => const UserModel(
        id: 'demo_officer_002',
        fullName: 'Inspector T. Dorjee',
        email: 't.dorjee@ner-police.gov.in',
        phone: '+91 94350 11223',
        role: UserRole.fieldOfficer,
        state: 'Arunachal Pradesh',
        district: 'West Kameng',
        village: 'Dirang HQ',
        badgeNumber: 'FO-NER-2026-88',
        token: 'mock_jwt_officer_token_sih2026',
        isDemoUser: true,
      );

  static UserModel get demoAdmin => const UserModel(
        id: 'demo_admin_003',
        fullName: 'Dr. P. K. Hazarika (Director)',
        email: 'director@sdma.arunachal.gov.in',
        phone: '+91 94351 99887',
        role: UserRole.authorityAdmin,
        state: 'Arunachal Pradesh',
        district: 'Papum Pare',
        village: 'Itanagar SDMA Command',
        badgeNumber: 'DIR-SDMA-001',
        token: 'mock_jwt_admin_token_sih2026',
        isDemoUser: true,
      );
}
